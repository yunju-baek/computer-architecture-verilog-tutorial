#!/usr/bin/env python3
"""Generate the normal instruction trace and final state for HW01.

main runs with the input derived from student_id.txt (see student_input.py).
The output is reproducible: the same source and student ID give the same files.
"""
import hashlib
import json
from pathlib import Path

from scripts.student_input import StudentIdError, derive, describe, read_student_id, run_options
from tools.rv32i import AssemblyError, assemble, register_index, run, state_dict, write_trace

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "programs/state_contract.s"


def build_evidence(source: Path, evidence: Path, data: dict) -> dict:
    evidence.mkdir(parents=True, exist_ok=True)
    program = assemble(source)
    result = run(program, allow_step_limit=True, **run_options(program, data))
    total = sum(data["values"]) & 0xFFFFFFFF
    stored = result.memory_words.get(program.labels["result"], 0)
    restored = {
        name: result.registers[register_index(name)] == expected
        for name, expected in (("sp", data["sp"]), *data["saved"].items())
    }
    info = {
        **describe(data),
        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
        "halted": result.halted,
        "observed_result": f"0x{stored:08x}",
        "result_matches_sum": stored == total,
        "restored_after_main": restored,
    }
    write_trace(result.trace, evidence / "architectural_trace.csv")
    (evidence / "final_state.json").write_text(json.dumps(state_dict(result), indent=2) + "\n", encoding="utf-8")
    (evidence / "run_info.json").write_text(json.dumps(info, indent=2) + "\n", encoding="utf-8")
    return {"info": info, "transitions": len(result.trace), "instructions": len(program.instructions)}


def main():
    try:
        data = derive(read_student_id())
    except StudentIdError as error:
        raise SystemExit(f"STOP {error}")
    try:
        summary = build_evidence(SOURCE, ROOT / "evidence", data)
    except (AssemblyError, RuntimeError) as error:
        raise SystemExit(f"STOP {error}")
    info = summary["info"]
    print(f"WROTE evidence/ student_id={info['student_id']} instructions={summary['instructions']} "
          f"transitions={summary['transitions']} result={info['observed_result']}")
    if not info["halted"]:
        print("WARN main did not reach ebreak within 1000 instructions; inspect the trace for a loop")
    if not info["result_matches_sum"]:
        print("WARN result differs from the sum of your input values; check sum_array")
    broken = [name for name, ok in info["restored_after_main"].items() if not ok]
    if broken:
        print("WARN not restored after main: " + ", ".join(broken))


if __name__ == "__main__":
    main()
