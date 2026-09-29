# Verilog Check Assignments (English Edition)

[한국어 버전](../check_packet/README.md)

This unified package integrates the self-study guides, lecture slides, supplementary concepts, and automated verification assignments for Verilog tutorial chapters CH01 through CH10 into a single workspace. Students progress sequentially through tool configuration, slide review, RTL simulation, manual output prediction, and archive packaging.

---

## 1. Structured Workflow

| Stage | Activity | Primary Content | Reference Files & Commands |
|---|---|---|---|
| **Phase 1** | Prerequisites | Verify iverilog, vvp, make, and git under WSL(Ubuntu) or macOS | [Tool Setup and First Run](tool_setup_first_run.md) |
| **Phase 2** | Self-Study 1 & Check 1 | CH01–CH05 syntax, combinational and sequential logic, 20 predictions | Session 1 Slides, [Concepts](supplementary_concepts.md), [Check 1](check1/README.md) |
| **Phase 3** | Self-Study 2 & Check 2 | CH06–CH10 hierarchy, memories, FSMs, 17 predictions, boundary test extension | Session 2 Slides, [Check 2](check2/README.md) |
| **Phase 4** | Submission | Execute `make package` in each check directory and upload archives to LMS | `verilog_check1_<id>.zip`, `verilog_check2_<id>.zip` |

---

## 2. Directory Layout

```text
check_packet_en/
  README.md                   ← Unified guide and execution manual
  lms_announcement.md         ← LMS assignment posting template
  tool_setup_first_run.md     ← Tool installation guide (WSL/macOS)
  supplementary_concepts.md   ← Signed numbers, shifts, and latch mitigation
  Makefile                    ← Batch execution and packaging entry point
  examples/
    width_probe.v             ← Bit-width and addition overflow experiment
  common/                     ← Shared verification scripts and probe macros
  check1/                     ← Check 1 (CH01–CH05) workspace
    README.md  Makefile  student.mk  predictions.vh  report.md  integrity.txt  probes/
  check2/                     ← Check 2 (CH06–CH10) workspace
    README.md  Makefile  student.mk  predictions.vh  report.md  integrity.txt  probes/
```

---

## 3. Step-by-Step Instructions

### Step 1: Environment Setup
1. Follow [Tool Setup and First Run](tool_setup_first_run.md) to install `iverilog`, `vvp`, `make`, and `git`.
2. Run the tutorial CH01 verification test:
   ```bash
   make -C ../tutorial_en/ch01 test
   ```

### Step 2: Session 1 Study and Check 1 (CH01–CH05)
1. Review Session 1 Slides (`Verilog_01_CH01-CH05`) and [Supplementary Concepts](supplementary_concepts.md) alongside chapters ch01 to ch05.
2. Compile and run [examples/width_probe.v](examples/width_probe.v) to observe 4-bit vs. 5-bit addition truncation and carry handling.
3. Enter `check1/` and set your 9-digit student ID in `student.mk`.
4. Run `make show-inputs`, evaluate RTL modules, and compute 20 expected values in `predictions.vh`.
5. Run `make test` to verify that all 5 chapters pass (`PASS check1 all`).
6. Complete `report.md` and `integrity.txt`, then run `make package` to produce `verilog_check1_<id>.zip`.

### Step 3: Session 2 Study and Check 2 (CH06–CH10)
1. Review Session 2 Slides (`Verilog_02_CH06-CH10`) alongside chapters ch06 to ch10.
2. Enter `check2/` and configure `student.mk`.
3. Run `make show-inputs` and complete the 17 predictions in `predictions.vh`.
4. Run `make boundary` to copy `tb_boundary.v`, then insert the two `REQUIRED` boundary vectors to expand evaluation to 12 vectors.
5. Run `make test` to confirm `PASS check2 all`.
6. Complete `report.md` and `integrity.txt`, then run `make package` to produce `verilog_check2_<id>.zip`.

---

## 4. Execution Commands

Run commands individually within `check1/` or `check2/`, or run batch targets from the `check_packet_en/` root:

```bash
make setup-check      # Validate environment and record evidence/env.txt
make tutorial-check   # Run chapter tests for the respective range
make show-inputs      # Display derived test inputs (in check subdirectories)
make test             # Match prediction outputs against hardware simulation
make evidence         # Generate SHA-256 integrity manifest
make package          # Build LMS submission archive
make clean            # Remove build artifacts and temporary logs
```

---

## 5. Submission Guidelines

- Required files: `verilog_check1_<id>.zip`, `verilog_check2_<id>.zip`
- Platform and deadlines: consult [LMS Announcement](lms_announcement.md) and instructor notices.
- If execution errors persist, package the current state through `make package` and detail the reproduction command, initial error message, and debugging attempts in `report.md`.
