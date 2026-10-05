#!/usr/bin/env python3
"""Compare return PCs after replacing one ra restore with a same-size nop.

Run after recording a prediction in report.md. The submitted source stays intact.
The changed execution stops immediately after the relevant return instruction.
"""
from pathlib import Path
import argparse
import hashlib
import json

from tools.rv32i import assemble, register_index, parse_memory_operand, run, write_trace

ROOT = Path(__file__).resolve().parents[1]


def experiment(source: Path, output: Path, restore_line: int | None = None) -> dict:
    original = source.read_bytes()
    program = assemble(source)
    normal = run(program)
    if not normal.halted:
        raise ValueError("Complete the normal program before running this experiment.")
    candidates = [
        i for i in program.instructions.values()
        if i.op == "lw" and register_index(i.args[0]) == register_index("ra")
        and parse_memory_operand(i.args[1])[1] == register_index("sp")
    ]
    if restore_line is not None:
        candidates = [i for i in candidates if i.line == restore_line]
    if len(candidates) != 1:
        raise ValueError("Select the sum_array stack restore with RESTORE_LINE=<source line>.")
    restore = candidates[0]
    visits = [row for row in normal.trace if row["pc"] == restore.pc]
    if len(visits) != 1:
        raise ValueError("Choose a restore instruction executed once by the provided main.")
    restore_seq = int(visits[0]["seq"])
    returns = [
        row for row in normal.trace[restore_seq + 1:]
        if program.instructions[int(row["pc"])].op == "jalr"
        and register_index(program.instructions[int(row["pc"])].args[0]) == 0
        and parse_memory_operand(program.instructions[int(row["pc"])].args[1])[1] == 1
    ]
    if not returns:
        raise ValueError("The selected restore must precede a return through ra.")
    expected_return = returns[0]
    limit = int(expected_return["seq"]) + 1
    lines = original.decode().splitlines(keepends=True)
    line = lines[restore.line - 1]
    code = line.split("#", 1)[0]
    prefix = code.rsplit(":", 1)[0] + ": " if ":" in code else "  "
    lines[restore.line - 1] = prefix + "nop  # experiment: omit ra restore, preserve addresses\n"
    output.mkdir(parents=True, exist_ok=True)
    changed_source = output / "ra_omitted.s"
    changed_source.write_text("".join(lines))
    modified = assemble(changed_source)
    if program.labels != modified.labels or list(program.instructions) != list(modified.instructions):
        raise ValueError("The experiment must preserve instruction addresses and labels.")
    changed = run(modified, max_steps=limit, allow_step_limit=True)
    actual_return = changed.trace[-1]
    if actual_return["pc"] != expected_return["pc"]:
        raise ValueError("Execution diverged before the selected return; inspect the trace.")
    write_trace(normal.trace, output / "normal_trace.csv")
    write_trace(changed.trace, output / "ra_omitted_trace.csv")
    summary = {
        "source_sha256": hashlib.sha256(original).hexdigest(),
        "restore_source_line": restore.line,
        "restore_pc": restore.pc,
        "return_seq": expected_return["seq"],
        "return_pc": expected_return["pc"],
        "normal_next_pc": expected_return["next_pc"],
        "ra_omitted_next_pc": actual_return["next_pc"],
        "normal_completed": normal.halted,
        "capture_stop": "immediately after the selected return",
        "captured_instructions": len(changed.trace),
        "return_target_changed": expected_return["next_pc"] != actual_return["next_pc"],
    }
    if not summary["return_target_changed"]:
        raise ValueError("This restore did not change the return target; select the nested-call restore.")
    if source.read_bytes() != original:
        raise RuntimeError("The submitted assembly changed during the experiment.")
    (output / "comparison.json").write_text(json.dumps(summary, indent=2) + "\n")
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--restore-line", type=int)
    args = parser.parse_args()
    result = experiment(ROOT / "programs/state_contract.s", ROOT / "evidence/ra_experiment", args.restore_line)
    print(f"CAPTURED return PC=0x{result['return_pc']:08x} "
          f"normal next PC=0x{result['normal_next_pc']:08x} "
          f"ra-omitted next PC=0x{result['ra_omitted_next_pc']:08x}")


if __name__ == "__main__":
    main()
