# Verilog Check 1 — Tool Setup and CH01–CH05

## 1. Learning Objectives

Following self-study of CH01–CH05 from the initial lecture session, execute tutorial chapters 1 through 5 on your local machine. Analyze original RTL modules to calculate hardware outputs manually for inputs derived from your student ID, and verify calculations against simulation runtime outputs.

Check 1 verifies three core components:

| Verification Target | Method |
|---|---|
| Tool Setup | `make setup-check` verifies `iverilog`, `vvp`, `make`, and `git` versions, writing `evidence/env.txt` |
| Tutorial Execution | `make tutorial-check` executes `make test` across ch01–ch05 and saves per-chapter logs |
| RTL Analysis | `make test` automatically compares expected values in `predictions.vh` against hardware simulation |

Input values derive individually per student ID. Only predictions and simulation logs executed under your own student ID pass verification.

## 2. Prerequisites and References

| Chapter | Evaluated Source Module | Reference Slides (Session 1) |
|---|---|---|
| CH01 | `tutorial/ch01/ex02_inverter.v` | Slides 07–09 |
| CH02 | `tutorial/ch02/ex04_select.v` | Slides 10–12 |
| CH03 | `tutorial/ch03/ex02_width_rules.v`, `ex03_signed.v` | Slide 13 |
| CH04 | `tutorial/ch04/ex02_default.v`, `ex01_mux4.v` | Slides 14–15 |
| CH05 | `tutorial/ch05/ex03_control.v`, `ex02_blocking.v` | Slides 16–19 |

For tool setup procedures, consult [Tool Setup and First Run](../tool_setup_first_run.md) or [Tutorial CH01](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/ch01/). Review signed numbers, shifts, and latches in [Supplementary Concepts](../supplementary_concepts.md), and explore bit-width rules with [width_probe.v](../examples/width_probe.v).

## 3. Deliverable Files

| File | Content |
|---|---|
| `student.mk` | Single line configuring your 9-digit student ID |
| `predictions.vh` | 20 predicted outputs (replace `x` placeholders with calculated values) |
| `report.md` | Analysis of discrepancies between initial predictions and simulation, per-chapter summaries |
| `integrity.txt` | Verification checklist and student academic integrity pledge |

Maintain `probes/`, `Makefile`, and `../common/` unmodified.

## 4. Step-by-Step Workflow

1. Start inside the unified activity reports workspace (where `check1/` and `check2/` reside).
2. Navigate to `check1/` and set your 9-digit student ID in `student.mk`.
3. Run `make setup-check` and verify the `READY check1` message.
4. Run `make tutorial-check`. Confirm `PASS chNN` for each chapter. If an error occurs, inspect the first failure in `evidence/tutorial_chNN.log` to troubleshoot.
5. Run `make show-inputs` to display the inputs derived from your student ID. Analyze source RTL manually, compute outputs, and fill them into `predictions.vh`.
6. Run `make test`. `UNANSWERED` flags unassigned `x` entries, while `FAIL` flags calculation mismatches. Re-evaluate RTL and update values. When all 5 chapters pass, the terminal prints `PASS check1 all`.
7. Complete `report.md` and `integrity.txt`.
8. Run `make package` to generate the submission archive: `verilog_check1_<id>.zip`.

## 5. Execution Commands

```bash
cd check1
make setup-check        # Verify 4 tools, create evidence/env.txt
make tutorial-check     # Verify execution of tutorial ch01–ch05
make show-inputs        # Print inputs derived from student ID
make test               # Match predictions against simulation (prints 'PASS check1 all' on success)
make evidence           # Generate evidence/manifest.txt (SHA-256 manifest)
make package            # Create ../verilog_check1_<id>.zip
```

If `tutorial/` resides in an alternate path, pass it explicitly: `make test TUTORIAL=path`.

### Target Prediction Breakdown

| Chapter | Count | Target Logic and Derivation Basis |
|---|---:|---|
| CH01 | 1 | `y = ~a` inverter output |
| CH02 | 6 | 6 fixed-field bit slices from 32-bit instruction word |
| CH03 | 4 | 4-bit sum, 5-bit sum, carry-out, and `$signed` interpretation |
| CH04 | 5 | 4 `with_default` control decoder outputs, 1 `ex01_mux4` multiplexer output |
| CH05 | 4 | 3 state transitions (`reset` > `load` > `enable` priority), 1 non-blocking shift register output |

The CH05 transition sequence prints during `make show-inputs`. Inputs transition on clock falling edges; probes sample states at `#1` following rising edges.

## 6. Report Guidelines

Complete the 3 sections in `report.md`:

1. Environment Audit: Record OS and `iverilog` versions from `evidence/env.txt`, documenting 1 resolved technical issue during setup or execution.
2. Prediction vs. Simulation Analysis: Document 2 items where manual predictions initially differed from simulation outputs. If all initial predictions matched, analyze the 2 most complex signals and provide full derivation rationales.
3. Chapter Takeaways: Summarize the core hardware mechanisms of CH01–CH05 concisely in your own words.

Limit report body to approximately 1 page. Focus on quantitative observations and hardware mechanics; logs are preserved under `evidence/`.

## 7. Submission Checklist

- Run `make clean` followed by `make package`, confirming clean completion with `PASS ../verilog_check1_<id>.zip`.
- Verify the generated zip contains `student.mk`, `predictions.vh`, `report.md`, `integrity.txt`, and `evidence/`.
- Verify `evidence/` contains `env.txt`, `tutorial_ch01.log`–`tutorial_ch05.log`, `probe_ch01.log`–`probe_ch05.log`, and `manifest.txt`.
- Unassigned `x` entries in `predictions.vh` cause `make test` to halt with `UNANSWERED`.
- Upload target and deadlines follow LMS course announcements.

Submissions will be unpacked in an isolated grading workspace where `make test` is re-executed and matched against submitted logs and cryptographic manifests. If execution issues persist, document reproduction commands and primary error messages in Section 1 of `report.md`, package available outputs via `make evidence`, and submit.
