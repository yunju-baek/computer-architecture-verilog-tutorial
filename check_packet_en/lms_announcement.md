# [Announcement] Verilog Self-Study and Activity Assignments (Check 1 & Check 2)

Dear Computer Architecture Students,

This announcement outlines the **Check 1 and Check 2 Activity Assignments** corresponding to the Verilog 10-chapter tutorial series (CH01–CH10).
Please download the student distribution package, complete the self-study modules in your local terminal environment, and submit your generated verification archives to the LMS assignment portal.

---

## 1. Assignment Scope and Schedule

| Assessment | Scope | Key Activities | Deliverable |
|---|---|---|---|
| **Check 1** | CH01–CH05 | Environment setup, 5-chapter tutorial execution, bit-width probe, 20 prediction checks | `verilog_check1_<id>.zip` |
| **Check 2** | CH06–CH10 | Hierarchy, memories, FSMs, 17 prediction checks, 12-vector boundary test expansion | `verilog_check2_<id>.zip` |

- **Official Release Download**: [Tutorial repository ZIP](https://github.com/yunju-baek/computer-architecture-verilog-tutorial/archive/refs/heads/main.zip)
- **Online Repository**: [English check assignments](https://github.com/yunju-baek/computer-architecture-verilog-tutorial/tree/main/check_packet_en)

---

## 2. Included Package Reference Documents

Inside the extracted student package, the `check_packet_en/` directory provides the following guides and workspaces:

- **`tool_setup_first_run.md`**: Step-by-step setup guide for `iverilog`, `vvp`, `make`, and `git` under WSL (Ubuntu) and macOS
- **`supplementary_concepts.md`**: Core engineering review on signed arithmetic, logical vs. arithmetic shifts, and latch mitigation
- **`check1/README.md`**: Check 1 (CH01–CH05) detailed workflow specification
- **`check2/README.md`**: Check 2 (CH06–CH10) detailed workflow specification
- **`examples/width_probe.v`**: Verilog test bench demonstrating truncation and carry propagation
- **Lecture Slides**: Reference decks for Session 1 (`Verilog_01_CH01-CH05.pdf`) and Session 2 (`Verilog_02_CH06-CH10.pdf`)

---

## 3. Step-by-Step Instructions

### Step 1: Tool Installation and Verification
1. Download the package from the tutorial repository and extract it to your working directory.
2. Consult `tool_setup_first_run.md` to verify the required tools in your terminal.
3. Test the tutorial environment:
   ```bash
   make -C tutorial_en/ch01 test
   ```

### Step 2: Check 1 Assignment (CH01–CH05)
1. Review the Session 1 lecture slides and `supplementary_concepts.md` alongside chapters ch01 to ch05.
2. Navigate to `check_packet_en/check1/` and set your 9-digit student ID in `student.mk`.
3. Execute `make show-inputs` to obtain your unique test vector, evaluate the RTL modules, and complete the 20 prediction entries in `predictions.vh`.
4. Run `make test` to verify that all 5 chapters pass (`PASS check1 all`).
5. Complete `report.md` and `integrity.txt`, then run `make package` to produce `verilog_check1_<id>.zip` and upload it to the LMS Check 1 portal.

### Step 3: Check 2 Assignment (CH06–CH10)
1. Review the Session 2 lecture slides alongside chapters ch06 to ch10.
2. Navigate to `check_packet_en/check2/` and configure `student.mk` with your student ID.
3. Run `make show-inputs` and complete the 17 predictions in `predictions.vh`.
4. Execute `make boundary` to generate `tb_boundary.v`, then insert the two `REQUIRED` boundary vectors to expand evaluation to 12 vectors.
5. Run `make test` to confirm `PASS check2 all`.
6. Complete `report.md` and `integrity.txt`, then run `make package` to produce `verilog_check2_<id>.zip` and upload it to the LMS Check 2 portal.

---

## 4. Submission Notes

- **Deterministic Evaluation**: Test vectors derive deterministically from your student ID. Valid submissions require all checks to pass under your own ID.
- **Automated Verification**: Submitted packages undergo isolated server-side re-execution and cryptographic hash checks.
- **Issue Reporting**: In case of persistent environment errors, package the work via `make package` and document the command, initial error message, and debugging attempts in `report.md`.
