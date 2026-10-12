#!/usr/bin/env python3
"""Check the HW01 folder and create submit/hw01_<student ID>.zip for the LMS.

Incomplete work can still be packaged. Each missing or stale item is printed as
WARN so it can be fixed before the deadline. Upload only the created ZIP file.
"""
from __future__ import annotations

import hashlib
import importlib.util
import io
import json
import re
import sys
import unittest
import zipfile
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

from scripts.student_input import StudentIdError, read_student_id

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "programs/state_contract.s"
SKIP_DIRS = {"build", "submit", "__pycache__", ".git"}
SKIP_NAMES = {".DS_Store", "Thumbs.db"}
SKIP_SUFFIXES = {".pyc", ".zip"}
REQUIRED = (
    "programs/state_contract.s",
    "tests/test_student_cases.py",
    "report.md",
    "integrity.txt",
    "student_id.txt",
    "evidence/architectural_trace.csv",
    "evidence/final_state.json",
    "evidence/run_info.json",
    "evidence/ra_experiment/normal_trace.csv",
    "evidence/ra_experiment/ra_omitted.s",
    "evidence/ra_experiment/ra_omitted_trace.csv",
    "evidence/ra_experiment/comparison.json",
)
PLACEHOLDER = re.compile(r"<작성>|<write>|\[Fill in\]")


def split_item(line: str) -> tuple[str, str] | None:
    """Split '- label (note: x): answer' at the first colon outside parentheses."""
    depth = 0
    for index, char in enumerate(line):
        if char == "(":
            depth += 1
        elif char == ")":
            depth = max(0, depth - 1)
        elif char == ":" and depth == 0:
            return line[2:index], line[index + 1:]
    return None


def blank_items(text: str) -> list[str]:
    """Required '- label:' items with nothing after the colon or on the following lines."""
    lines = text.splitlines()
    blanks = []
    for index, line in enumerate(lines):
        parts = split_item(line) if line.startswith("- ") else None
        if parts is None:
            continue
        label, answer = parts
        if answer.strip() or "선택" in label or "optional" in label.lower():
            continue
        following = next((item for item in lines[index + 1:] if item.strip()), "- ")
        if following.startswith("- "):
            blanks.append(label.strip())
    return blanks


def run_suite(path: Path) -> tuple[int, int]:
    if str(ROOT) not in sys.path:
        sys.path.insert(0, str(ROOT))
    sink = io.StringIO()
    with redirect_stdout(sink), redirect_stderr(sink):
        try:
            spec = importlib.util.spec_from_file_location(f"hw01_package_{path.stem}", path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            suite = unittest.defaultTestLoader.loadTestsFromModule(module)
            result = unittest.TextTestRunner(stream=sink, verbosity=0).run(suite)
        except Exception:
            return 0, 1
    failed = len(result.failures) + len(result.errors)
    return result.testsRun - failed, result.testsRun


def evidence_warnings(student_id: str) -> list[str]:
    warnings = []
    source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest() if SOURCE.is_file() else ""
    for name, command in (("evidence/run_info.json", "make evidence"),
                          ("evidence/ra_experiment/comparison.json", "make ra-experiment")):
        path = ROOT / name
        if not path.is_file():
            continue
        try:
            info = json.loads(path.read_text(encoding="utf-8"))
        except ValueError:
            warnings.append(f"{name} is unreadable; run {command} again")
            continue
        if info.get("student_id") != student_id:
            warnings.append(f"{name} was made for student ID {info.get('student_id')}; run {command} again")
        elif info.get("source_sha256") != source_hash:
            warnings.append(f"{name} is older than programs/state_contract.s; run {command} again")
    return warnings


def collect_warnings(student_id: str) -> list[str]:
    warnings = [f"missing {name}" for name in REQUIRED if not (ROOT / name).is_file()]
    warnings += evidence_warnings(student_id)
    if SOURCE.is_file() and "TODO" in SOURCE.read_text(encoding="utf-8"):
        warnings.append("programs/state_contract.s still contains TODO")
    tests = ROOT / "tests/test_student_cases.py"
    if tests.is_file() and "TODO" in tests.read_text(encoding="utf-8"):
        warnings.append("tests/test_student_cases.py still contains TODO")
    report = ROOT / "report.md"
    if report.is_file():
        blanks = len(PLACEHOLDER.findall(report.read_text(encoding="utf-8")))
        if blanks:
            warnings.append(f"report.md has {blanks} unfilled placeholders")
    integrity = ROOT / "integrity.txt"
    if integrity.is_file():
        empty = blank_items(integrity.read_text(encoding="utf-8"))
        if empty:
            warnings.append(f"integrity.txt has {len(empty)} required items left blank")
    for label, path in (("public assembly tests", ROOT / "tests/test_public_state.py"),
                        ("student tests", tests)):
        if path.is_file():
            passed, total = run_suite(path)
            if passed != total:
                warnings.append(f"{label}: {passed}/{total} passed (run make test for details)")
    return warnings


def package(student_id: str) -> tuple[Path, int]:
    target = ROOT / "submit" / f"hw01_{student_id}.zip"
    target.parent.mkdir(exist_ok=True)
    folder = f"hw01_{student_id}"
    files = sorted(
        path for path in ROOT.rglob("*")
        if path.is_file()
        and not SKIP_DIRS.intersection(path.relative_to(ROOT).parts)
        and path.name not in SKIP_NAMES
        and path.suffix not in SKIP_SUFFIXES
    )
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, f"{folder}/{path.relative_to(ROOT).as_posix()}")
    return target, len(files)


def main() -> None:
    try:
        student_id = read_student_id()
    except StudentIdError as error:
        raise SystemExit(f"STOP {error}")
    warnings = collect_warnings(student_id)
    target, count = package(student_id)
    for warning in warnings:
        print(f"WARN {warning}")
    print(f"CREATED {target.relative_to(ROOT).as_posix()} files={count} warnings={len(warnings)}")
    print("Upload this ZIP file to the HW01 entry on the LMS. Fix WARN items and run make package again if time allows.")


if __name__ == "__main__":
    main()
