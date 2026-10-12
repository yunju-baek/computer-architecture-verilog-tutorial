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
    expected = {f"archlab-{hw}-{language}.zip" for hw in ALLOWED for language in ("ko", "en")}
    assert set(data["packages"]) == expected, sorted(data["packages"])
    assert {p.name for p in downloads.glob("*.zip")} == expected
    for name, record in data["packages"].items():
        path = downloads / name
        hw, language = record["assignment"], record["language"]
        assert name == f"archlab-{hw}-{language}.zip", name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == record["sha256"], name
        with ZipFile(path) as archive:
            assert archive.testzip() is None
            check_names(archive.namelist())
            assert len(archive.namelist()) == record["files"]
            with tempfile.TemporaryDirectory(prefix="public-hw-") as tmp:
                archive.extractall(tmp)
                package = next(Path(tmp).iterdir())
                check_links(package)
                tree = package / ("assignments_en" if language == "en" else "assignments")
                assert {p.name for p in tree.iterdir() if p.is_dir()} == {hw}, (name, "one assignment per download")
                tutorial = package / ("tutorial_en" if language == "en" else "tutorial")
                assert tutorial.is_dir() == (hw == "hw02"), (name, "tutorial only with hw02")
                for p in package.rglob("*"):
                    relative = p.relative_to(package)
                    if p.is_file() and len(relative.parts) > 1:
                        assert p.read_bytes() == (ROOT / relative).read_bytes(), p
    print("PASS public assignments: HW01/HW02 only, bilingual parity, links, one download per assignment")

if __name__ == "__main__":
    main()
