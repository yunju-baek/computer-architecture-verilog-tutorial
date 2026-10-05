#!/usr/bin/env python3
"""Validate the public assignment boundary, bilingual files, links, and downloads."""
from pathlib import Path
from zipfile import ZipFile
from urllib.parse import unquote
import hashlib, json, re, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {"hw01", "hw02"}
FORBIDDEN = {"solutions", "hidden_tests", "evaluation", "bonus", "rv32i_core.v", "rv32i_pipeline_core.v"}


def check_names(names):
    for name in names:
        parts = Path(name).parts
        assert not FORBIDDEN.intersection(parts), name
        assert not any("lms" in part.lower() for part in parts), name
        assert not any(re.fullmatch(r"hw0[3-9]", x) for x in parts), name
        assert ".." not in parts and not Path(name).is_absolute(), name


def check_links(root):
    for path in root.rglob("*.md"):
        for target in re.findall(r"\[[^\]]*\]\(([^)]+)\)", path.read_text()):
            target = target.split("#", 1)[0].strip("<>")
            if target and not target.startswith(("https://", "http://", "mailto:")):
                assert (path.parent / unquote(target)).exists(), (path, target)


def main():
    for path in ROOT.rglob("*"):
        if path.is_file() and ".git" not in path.parts:
            assert "lms" not in path.name.lower(), path
    manifest = json.loads((ROOT / "release_manifest.json").read_text())
    assert set(manifest["assignments"]) == ALLOWED
    for directory in ("assignments", "assignments_en"):
        base = ROOT / directory
        assert {p.name for p in base.iterdir() if p.is_dir()} == ALLOWED
        check_names(p.relative_to(base).as_posix() for p in base.rglob("*") if p.is_file())
        check_links(base)
        for hw in sorted(ALLOWED):
            work = base / hw
            for name in ("README.md", "report.md", "integrity.txt", "Makefile"):
                assert (work / name).is_file(), (directory, hw, name)
            assert len(re.findall(r"^## ", (work / "report.md").read_text(), re.M)) == 4
            if hw == "hw02":
                assert "## HW03 state and observation" not in (work / "CONTRACT.md").read_text()
                assert "dut.rf.regs" not in (work / "CONTRACT.md").read_text()
            subprocess.run(["make", "setup-check"], cwd=work, check=True)
    for hw in sorted(ALLOWED):
        for path in (ROOT / "assignments" / hw).rglob("*"):
            if path.is_file() and (path.suffix in (".v", ".py", ".s", ".c") or path.name == "Makefile"):
                assert path.read_bytes() == (ROOT / "assignments_en" / hw / path.relative_to(ROOT / "assignments" / hw)).read_bytes(), path
    downloads = ROOT / "downloads"
    data = json.loads((downloads / "manifest.json").read_text())
    assert set(data["published_assignments"]) == ALLOWED
    assert set(data["packages"]) == {"archlab-hw01-hw02-ko.zip", "archlab-hw01-hw02-en.zip"}
    assert {p.name for p in downloads.glob("*.zip")} == set(data["packages"])
    for name, record in data["packages"].items():
        path = downloads / name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == record["sha256"], name
        with ZipFile(path) as archive:
            assert archive.testzip() is None
            check_names(archive.namelist())
            assert len(archive.namelist()) == record["files"]
            with tempfile.TemporaryDirectory(prefix="public-hw12-") as tmp:
                archive.extractall(tmp)
                package = next(Path(tmp).iterdir())
                check_links(package)
                tree = package / ("assignments_en" if name.endswith("-en.zip") else "assignments")
                assert {p.name for p in tree.iterdir() if p.is_dir()} == ALLOWED
                for p in tree.rglob("*"):
                    if p.is_file() and p.name != "README.md":
                        source = ROOT / tree.name / p.relative_to(tree)
                        assert p.read_bytes() == source.read_bytes(), p
    print("PASS public assignments: HW01/HW02 only, bilingual parity, links, download hashes")

if __name__ == "__main__":
    main()
