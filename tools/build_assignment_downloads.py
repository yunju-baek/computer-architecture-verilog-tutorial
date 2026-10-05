#!/usr/bin/env python3
"""Build the two public assignment downloads from an explicit allowlist."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED
import hashlib, json

ROOT = Path(__file__).resolve().parents[1]
PUBLISHED = ("hw01", "hw02")

def package_files(language):
    assignments = "assignments" if language == "ko" else "assignments_en"
    tutorial = "tutorial" if language == "ko" else "tutorial_en"
    files = {}
    for base in [ROOT / assignments / hw for hw in PUBLISHED] + [ROOT / tutorial]:
        for path in sorted(base.rglob("*")):
            if not path.is_file() or any(x in path.parts for x in ("build", "evidence", "__pycache__")):
                continue
            if "lms" in path.name.lower() or path.name == ".DS_Store" or path.suffix in (".pyc", ".vcd", ".vvp", ".zip"):
                continue
            files[path.relative_to(ROOT).as_posix()] = path.read_bytes()
    index = (ROOT / assignments / "README.md").read_text()
    index = index[:index.rfind("\n[")].rstrip() + "\n"
    files[assignments + "/README.md"] = index.encode()
    title = "# HW01–HW02 학생 배포본" if language == "ko" else "# HW01–HW02 student package"
    intro = ("HW01과 HW02의 학생 구현 자료와 Verilog 자습서를 제공한다. HW03·HW04는 주제 소개 단계이다.\n"
             if language == "ko" else "This package contains HW01 and HW02 plus the Verilog tutorial. HW03 and HW04 have topic previews only.\n")
    files["README.md"] = (title + "\n\n" + intro + "\n[Assignments](" + assignments + "/README.md) · [Tutorial](" + tutorial + "/README.md)\n\n```bash\nmake package-check\ncd " + assignments + "/hw01\nmake setup-check\n```\n").encode()
    files["VERSION"] = b"archlab-3.0.0-hw01-hw02\n"
    files["Makefile"] = ("ASSIGNMENTS := " + assignments + "/hw01 " + assignments + "/hw02\n"
        + ".PHONY: help package-check test evidence clean\n"
        + "help:\n\t@echo 'make package-check; implement each assignment; make test; make evidence'\n"
        + "package-check:\n\t$(MAKE) -C " + tutorial + " test\n\t@for d in $(ASSIGNMENTS); do $(MAKE) -C $$d setup-check || exit 1; done\n"
        + "test:\n\t@for d in $(ASSIGNMENTS); do $(MAKE) -C $$d test || exit 1; done\n"
        + "evidence:\n\t$(MAKE) -C " + assignments + "/hw01 evidence ra-experiment\n\t$(MAKE) -C " + assignments + "/hw02 evidence\n"
        + "clean:\n\t$(MAKE) -C " + tutorial + " clean\n\t@for d in $(ASSIGNMENTS); do $(MAKE) -C $$d clean || exit 1; done\n").encode()
    return files

def main():
    downloads = ROOT / "downloads"
    downloads.mkdir(exist_ok=True)
    manifest = {"published_assignments": list(PUBLISHED), "packages": {}}
    for language in ("ko", "en"):
        stem = "archlab-hw01-hw02-" + language
        files = package_files(language)
        path = downloads / (stem + ".zip")
        with ZipFile(path, "w") as archive:
            for name, content in sorted(files.items()):
                info = ZipInfo(stem + "/" + name, date_time=(2026, 10, 5, 0, 0, 0))
                info.compress_type = ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                archive.writestr(info, content)
        manifest["packages"][path.name] = {"files": len(files), "bytes": path.stat().st_size, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    (downloads / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("PASS built HW01/HW02-only downloads")

if __name__ == "__main__":
    main()
