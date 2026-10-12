#!/usr/bin/env python3
"""Build one public download per assignment and language from an explicit allowlist.

Each ZIP keeps the repository layout (assignments/hwNN/), so ZIP users and clone
users follow the same paths. HW02 links the Verilog tutorial, so its ZIP also
carries the tutorial of the same language.
"""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED
import hashlib, json

ROOT = Path(__file__).resolve().parents[1]
PUBLISHED = ("hw01", "hw02")
LANGUAGES = ("ko", "en")
VERSION = "archlab-3.0.1"
DATE = (2026, 10, 12, 0, 0, 0)
WITH_TUTORIAL = {"hw02"}
TITLES = {
    ("hw01", "ko"): "HW01 함수 호출과 아키텍처 상태", ("hw01", "en"): "HW01 Function calls and architectural state",
    ("hw02", "ko"): "HW02 프로세서 구성 모듈", ("hw02", "en"): "HW02 Processor building blocks",
}
SKIP_DIRS = {"build", "evidence", "submit", "__pycache__"}


def stem(hw, language):
    return f"archlab-{hw}-{language}"


def collect(base, files):
    for path in sorted(base.rglob("*")):
        if not path.is_file() or SKIP_DIRS.intersection(path.parts):
            continue
        if "lms" in path.name.lower() or path.name == ".DS_Store" or path.suffix in (".pyc", ".vcd", ".vvp", ".zip"):
            continue
        files[path.relative_to(ROOT).as_posix()] = path.read_bytes()


def readme(hw, language, assignments, tutorial):
    guide = f"{assignments}/{hw}/README.md"
    if language == "ko":
        lines = [f"# {TITLES[hw, language]}", "", f"과제 안내는 [{guide}]({guide})에 있다."]
        if hw in WITH_TUTORIAL:
            lines += ["", f"선행 학습용 [Verilog 자습서]({tutorial}/README.md)를 함께 제공한다."]
    else:
        lines = [f"# {TITLES[hw, language]}", "", f"The assignment guide is [{guide}]({guide})."]
        if hw in WITH_TUTORIAL:
            lines += ["", f"The [Verilog tutorial]({tutorial}/README.md) is included for preparation."]
    commands = (["make package-check"] if hw in WITH_TUTORIAL else []) + [f"cd {assignments}/{hw}", "make setup-check"]
    return "\n".join(lines + ["", "```bash", *commands, "```", ""])


def makefile(hw, assignments, tutorial):
    work = f"{assignments}/{hw}"
    return (".PHONY: help package-check test evidence clean\n"
            "help:\n\t@echo 'make package-check; implement the assignment; make test; make evidence'\n"
            f"package-check:\n\t$(MAKE) -C {tutorial} test\n\t$(MAKE) -C {work} setup-check\n"
            f"test:\n\t$(MAKE) -C {work} test\n"
            f"evidence:\n\t$(MAKE) -C {work} evidence\n"
            f"clean:\n\t$(MAKE) -C {tutorial} clean\n\t$(MAKE) -C {work} clean\n")


def package_files(hw, language):
    assignments = "assignments" if language == "ko" else "assignments_en"
    tutorial = "tutorial" if language == "ko" else "tutorial_en"
    files = {}
    collect(ROOT / assignments / hw, files)
    if hw in WITH_TUTORIAL:
        collect(ROOT / tutorial, files)
        files["Makefile"] = makefile(hw, assignments, tutorial).encode()
    files["README.md"] = readme(hw, language, assignments, tutorial).encode()
    files["VERSION"] = f"{VERSION}-{hw}\n".encode()
    return files


def main():
    downloads = ROOT / "downloads"
    downloads.mkdir(exist_ok=True)
    manifest = {"version": VERSION, "published_assignments": list(PUBLISHED), "packages": {}}
    expected = set()
    for hw in PUBLISHED:
        for language in LANGUAGES:
            name = stem(hw, language)
            files = package_files(hw, language)
            path = downloads / (name + ".zip")
            expected.add(path.name)
            with ZipFile(path, "w") as archive:
                for relative, content in sorted(files.items()):
                    info = ZipInfo(name + "/" + relative, date_time=DATE)
                    info.compress_type = ZIP_DEFLATED
                    info.external_attr = 0o100644 << 16
                    archive.writestr(info, content)
            manifest["packages"][path.name] = {
                "assignment": hw, "language": language, "files": len(files),
                "bytes": path.stat().st_size, "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
    for stale in downloads.glob("*.zip"):
        if stale.name not in expected:
            stale.unlink()
    (downloads / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("PASS built per-assignment downloads: " + ", ".join(sorted(expected)))


if __name__ == "__main__":
    main()
