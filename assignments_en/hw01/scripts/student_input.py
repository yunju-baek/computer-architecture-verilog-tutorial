#!/usr/bin/env python3
"""Derive the per-student HW01 evidence input from student_id.txt.

The same student ID always yields the same input. Each ID selects its own four
array values, starting sp, and starting s0-s2 values, so the trace rows and the
report numbers belong to that student. The public tests keep the default input
{5, -2, 9, -7}.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ID_FILE = ROOT / "student_id.txt"
ID_PATTERN = re.compile(r"[0-9]{8,10}")
INPUT_RULE = "archlab-2026-2/hw01/v1"
SAVED_REGISTERS = ("s0", "s1", "s2")


class StudentIdError(ValueError):
    """Raised when student_id.txt is missing or does not hold a student ID."""


def read_student_id(path: Path = ID_FILE) -> str:
    if not path.is_file():
        raise StudentIdError("student_id.txt is missing; create it and write your student ID")
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        text = line.split("#", 1)[0].strip()
        if not text:
            continue
        if ID_PATTERN.fullmatch(text):
            return text
        raise StudentIdError(f"student_id.txt: '{text}' must be your student ID, 8-10 digits")
    raise StudentIdError("student_id.txt: write your student ID (digits only) on a line without '#'")


def derive(student_id: str) -> dict:
    digest = hashlib.sha256(f"{INPUT_RULE}:{student_id}".encode("utf-8")).digest()
    values = []
    for index in range(4):
        raw = int.from_bytes(digest[2 * index:2 * index + 2], "big") % 1999 - 999
        values.append(raw if raw else index + 1)
    if all(value > 0 for value in values):
        values[1] = -values[1]
    if all(value < 0 for value in values):
        values[2] = -values[2]
    sp = 0x800 - 0x10 * (digest[8] % 32)
    saved = {
        name: ((index + 1) << 28) | int.from_bytes(digest[12 + 3 * index:15 + 3 * index], "big")
        for index, name in enumerate(SAVED_REGISTERS)
    }
    return {"student_id": student_id, "values": values, "sp": sp, "saved": saved}


def run_options(program, data: dict) -> dict:
    """Keyword arguments for tools.rv32i.run that apply the student input to main."""
    base = program.labels["values"]
    return {
        "initial_registers": {"sp": data["sp"], **data["saved"]},
        "memory_words": {base + 4 * index: value for index, value in enumerate(data["values"])},
    }


def describe(data: dict) -> dict:
    return {
        "student_id": data["student_id"],
        "input_rule": INPUT_RULE,
        "values_decimal": data["values"],
        "values_hex": [f"0x{value & 0xFFFFFFFF:08x}" for value in data["values"]],
        "initial_sp": f"0x{data['sp']:08x}",
        "initial_saved": {name: f"0x{value:08x}" for name, value in data["saved"].items()},
    }


def main() -> None:
    try:
        data = derive(read_student_id())
    except StudentIdError as error:
        raise SystemExit(f"STOP {error}")
    print(json.dumps(describe(data), indent=2))
    print("Predict the sum of values_decimal in report.md section 2 before running make evidence.")


if __name__ == "__main__":
    main()
