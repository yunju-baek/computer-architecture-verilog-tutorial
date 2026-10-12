#!/usr/bin/env python3
"""Compare return PCs after replacing one ra restore with a same-size nop.

Run after recording a prediction in report.md. The submitted source stays intact.
The changed execution stops immediately after the relevant return instruction.
Both runs use the input derived from student_id.txt (see student_input.py).
"""
from pathlib import Path
import argparse
import hashlib
import json

from scripts.student_input import StudentIdError, derive, read_student_id, run_options
from tools.rv32i import AssemblyError, assemble, register_index, parse_memory_operand, run, write_trace

ROOT = Path(__file__).resolve().parents[1]


def experiment(source: Path, output: Path, restore_line: int | None = None, data: dict | None = None) -> dict:
    original = source.read_bytes()
    program = assemble(source)
    options = run_options(program, data) if data else {}
    normal = run(program, allow_step_limit=True, **options)
    if not normal.halted:
        raise ValueError("Complete the normal program before running this experiment.")
    candidates = [
        i for i in program.instructions.values()
        if i.op == "lw" and register_index(i.args[0]) == register_index("ra")
        and parse_memory_operand(i.args[1])[1] == register_index("sp")
    ]
    if not candidates:
        raise ValueError("No 'lw ra, offset(sp)' found; save ra on the stack in sum_array and restore it before ret.")
    if restore_line is not None:
        candidates = [i for i in candidates if i.line == restore_line]
        if not candidates:
            raise ValueError(f"RESTORE_LINE={restore_line} is not a 'lw ra, offset(sp)' line of programs/state_contract.s.")
    if len(candidates) != 1:
        lines = ", ".join(str(i.line) for i in candidates)
        raise ValueError(f"Several ra restores (source lines {lines}); choose the sum_array one with RESTORE_LINE=<line>.")
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
    lines = original.decode("utf-8").splitlines(keepends=True)
    line = lines[restore.line - 1]
    code = line.split("#", 1)[0]
    prefix = code.rsplit(":", 1)[0] + ": " if ":" in code else "  "
    lines[restore.line - 1] = prefix + "nop  # experiment: omit ra restore, preserve addresses\n"
    output.mkdir(parents=True, exist_ok=True)
    changed_source = output / "ra_omitted.s"
    changed_source.write_text("".join(lines), encoding="utf-8")
    modified = assemble(changed_source)
    if program.labels != modified.labels or list(program.instructions) != list(modified.instructions):
        raise ValueError("The experiment must preserve instruction addresses and labels.")
    changed = run(modified, max_steps=limit, allow_step_limit=True, **options)
    actual_return = changed.trace[-1]
    if actual_return["pc"] != expected_return["pc"]:
        raise ValueError("Execution diverged before the selected return; inspect the trace.")
    write_trace(normal.trace, output / "normal_trace.csv")
    write_trace(changed.trace, output / "ra_omitted_trace.csv")
    summary = {
        "student_id": data["student_id"] if data else None,
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
    for key in ("normal_next_pc", "ra_omitted_next_pc"):
        target = program.instructions.get(summary[key])
        summary[key.replace("_pc", "_instruction")] = target.source if target else "(no instruction at this address)"
    summary["hex"] = {
        key: f"0x{summary[key]:08x}"
        for key in ("restore_pc", "return_pc", "normal_next_pc", "ra_omitted_next_pc")
    }
    if not summary["return_target_changed"]:
        raise ValueError("This restore did not change the return target; select the nested-call restore.")
    if source.read_bytes() != original:
        raise RuntimeError("The submitted assembly changed during the experiment.")
    (output / "comparison.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--restore-line", type=int)
    args = parser.parse_args()
    try:
        data = derive(read_student_id())
    except StudentIdError as error:
        raise SystemExit(f"STOP {error}")
    try:
        result = experiment(ROOT / "programs/state_contract.s", ROOT / "evidence/ra_experiment", args.restore_line, data)
    except (AssemblyError, RuntimeError, ValueError) as error:
        raise SystemExit(f"STOP {error}")
    print(f"CAPTURED return PC=0x{result['return_pc']:08x} "
          f"normal next PC=0x{result['normal_next_pc']:08x} "
          f"ra-omitted next PC=0x{result['ra_omitted_next_pc']:08x}")


if __name__ == "__main__":
    main()
