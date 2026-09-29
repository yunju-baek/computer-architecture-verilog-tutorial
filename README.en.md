# Computer Architecture Verilog Tutorial

[ 🇰🇷 한국어 ](README.md) | [ 🇺🇸 English ](README.en.md) | [ 🌐 Webbook (KO) ](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/) | [ 🌐 Webbook (EN) ](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/)

This is an executable Verilog tutorial designed for the Computer Architecture course at Pusan National University. Students compile RTL and self-checking testbenches with Icarus Verilog, inspecting simulation outputs and VCD waveforms to understand architectural state transitions and data movement.

The online chapter-by-chapter webbook is hosted at **[Verilog for Computer Architecture Webbook (EN)](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/)** (Korean edition: [Webbook in Korean](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/)). Click the language selector (`[KO | EN]`) in the top-right corner of any page to switch seamlessly between the English and Korean editions.

## Learning Objectives

- Read and author Verilog-2001 combinational and sequential logic descriptions.
- Execute self-checking testbenches via `iverilog` and `vvp`.
- Correlate `PASS`/`FAIL` assertions, VCD waveforms, and CSV traces with hardware circuit behavior.
- Diagnose compiler error messages and signal anomalies across intentional failure examples.

## Quickstart

Prerequisites are Git, GNU Make, and Icarus Verilog. Webbook generation requires Python 3. GTKWave is an optional waveform viewer. Commands adhere to POSIX shell conventions (macOS, Linux, WSL).

```bash
git clone https://github.com/yunju-baek/computer-architecture-verilog-tutorial.git
cd computer-architecture-verilog-tutorial
make setup-check
make test-en    # Runs the English tutorial test suite
```

When all examples pass, the final line prints `PASS tutorial all`.

## Key Commands

| Command | Function |
|---|---|
| `make setup-check` | Verify `iverilog` and `vvp` toolchain installations |
| `make test` | Execute all 10 chapter test suites (Korean tree) |
| `make test-en` | Execute all 10 chapter test suites (English tree) |
| `make errors` | Execute intentional defect examples to inspect compiler diagnostics |
| `make waves` | Generate Chapter 10 overview waveform and invoke GTKWave |
| `make webbook` | Build the 24-page static webbook (Korean & English) |
| `make webbook-check` | Validate Python syntax, build the webbook, and verify links |
| `make clean` | Clean compilation and webbook build artifacts |
| `make package-check` | Validate the entire public distribution package |
| `make check-packet-verify` | Verify compilation of all 10 verification probes |

Detailed table of contents and recommended study pathways are in [tutorial_en/README.md](tutorial_en/README.md) (Korean edition: [tutorial/README.md](tutorial/README.md)).

## Webbook Generation and Language Switching

The static webbook contains 24 pages across Korean and English (home page, Chapters 01–10, and quick reference appendix for each language).

- **Korean Edition**: [https://yunju-baek.github.io/computer-architecture-verilog-tutorial/](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/)
- **English Edition**: [https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/)

Every webbook page features a topbar language switcher (`[KO | EN]`), allowing instant switching between Korean and English versions of the current chapter. The selected language is saved in browser storage.

Run the verification target to build the webbook and validate all internal links:

```bash
make webbook-check
```

The GitHub Pages workflow on the `main` branch automatically deploys the built webbook upon passing all test suites.

## Course Assignments

Assignment materials are added sequentially to [`assignments/`](assignments/README.md) in accordance with the course syllabus and LMS announcements. Released assignments are version-pinned via repository commits and Git tags.

## Integrity and Academic Honor

Students are encouraged to consult official documentation, reference manuals, and instructional AI assistants as permitted by the course syllabus. Course announcements on LMS define authoritative submission boundaries. Each student is personally responsible for validating, understanding, and defending their submitted code, testbenches, and written analyses.

## Official Documentation

- [Icarus Verilog Usage](https://steveicarus.github.io/iverilog/usage/index.html)
- [GTKWave Documentation](https://gtkwave.sourceforge.net/gtkwave.pdf)
- [RISC-V ISA Manual](https://github.com/riscv/riscv-isa-manual/releases)
