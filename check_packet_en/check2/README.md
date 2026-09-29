# Verilog Check 2 — Module Interconnection, State, and Verification (CH06–CH10)

## 1. Learning Objectives

Following self-study of CH06–CH10 from the second lecture session, execute tutorial chapters 6 through 10 on your local machine. Analyze structural hierarchy, synchronous memory read timing, finite state machines (FSM), accumulator operations, and modern SystemVerilog syntax. Manually calculate expected outputs for inputs derived from your student ID, and verify calculations against simulation runtime outputs. In addition, extend the CH08 boundary-testing testbench using two student-specific test vectors.

| Verification Target | Method |
|---|---|
| Environment Audit | `make setup-check` verifies system configuration and writes `evidence/env.txt` |
| Tutorial Execution | `make tutorial-check` executes `make test` across ch06–ch10 and saves per-chapter logs |
| RTL Analysis | `make test` automatically compares 17 expected values in `predictions.vh` against simulation outputs |
| Testbench Extension | `make boundary-test` runs the extended `tb_boundary.v` with 12 vectors, validating 2 required boundary values |

Execute Check 2 within the same environment used for Check 1. Maintain identical `student.mk` configuration.

## 2. Prerequisites and References

| Chapter | Evaluated Source Module | Reference Slides (Session 2) |
|---|---|---|
| CH06 | `tutorial/ch06/ex03_generate.v` | Slides 03–05 |
| CH07 | `tutorial/ch07/ex02_sync_read.v`, `ex04_fsm.v` | Slides 06–11 |
| CH08 | `tutorial/ch08/ex01_dut.v`, `tb_ex03.v` | Slides 12–15, 20 |
| CH09 | `tutorial/ch09/ex01_synthesizable.v` | Slides 16–17 |
| CH10 | `tutorial/ch10/ex01_style.sv` | Slide 18 |

## 3. Deliverable Files

| File | Content |
|---|---|
| `student.mk` | Single line configuring your 9-digit student ID |
| `predictions.vh` | 17 predicted outputs (replace `x` placeholders with calculated values) |
| `tb_boundary.v` | Modified copy of `tutorial/ch08/tb_ex03.v` (extended to 12 vectors) |
| `report.md` | Prediction vs. simulation analysis, test coverage evaluation, chapter takeaways |
| `integrity.txt` | Verification checklist and student academic integrity pledge |

## 4. Step-by-Step Workflow

1. Navigate to `check2/` and configure your student ID in `student.mk`.
2. Run `make setup-check` and `make tutorial-check`, verifying `PASS chNN` for each chapter.
3. Run `make show-inputs` to display inputs and observe the two `REQUIRED` boundary values.
4. Read chapter source RTL and derive expected values, recording them in `predictions.vh`. Trace clock edge sequences for CH07 memory modules and follow state transition graphs for FSM modules.
5. Run `make boundary` to copy the initial `tb_boundary.v` template. Make three specific modifications:
   - Update `VECTOR_COUNT = 10` to `12`.
   - Assign the `REQUIRED` inputs to `boundary_values[10]` and `boundary_values[11]`, adding inline comments explaining the hardware edge conditions tested.
   - Update the final `$display` PASS banner to report 12 completed vectors. Use format specifier `%0d` with `VECTOR_COUNT` to synchronize printed counts with array dimensions.
   Preserve the original 10 test vectors, the 3 evaluation checks, and module identifier `tb_ex03` unmodified.
6. Run `make test`. When all 5 chapters pass alongside `PASS boundary-test`, the terminal outputs `PASS check2 all`.
7. Complete `report.md` and `integrity.txt`.
8. Run `make package` to produce the submission archive: `verilog_check2_<id>.zip`.

## 5. Execution Commands

```bash
cd check2
make setup-check        # Environment verification
make tutorial-check     # Batch execution of tutorial ch06–ch10
make show-inputs        # Display derived inputs and 2 REQUIRED boundary values
make boundary           # Generate initial working copy of tb_boundary.v
make test               # Verify 5 prediction probes and boundary-test in batch
make package            # Generate ../verilog_check2_<id>.zip
```

### Target Prediction Breakdown

| Chapter | Count | Target Logic and Derivation Basis |
|---|---:|---|
| CH06 | 3 | 8-bit sum, final carry-out, and intermediate carry between 4-bit stages |
| CH07 | 5 | Combinational vs. synchronous memory read outputs across clock edges (3 items), FSM detection count and final state |
| CH08 | 4 | Accumulated total across two sequential additions (2 items), zero flag, and carry flag |
| CH09 | 2 | Synthesizable pipeline `result` and `is_zero` flag after 3 operational stages |
| CH10 | 3 | `always_comb` multiplexer output, `always_ff` D flip-flop q output across two clock edges |

All sequential circuit probes drive inputs on clock falling edges and sample states at `#1` following rising edges. The CH07 synchronous read check demonstrates that when read and write access the same address within an active cycle, the synchronous memory outputs data registered during the preceding cycle.

## 6. Report Guidelines

Complete the 4 sections in `report.md`:

1. Prediction vs. Simulation Analysis: Document 2 items where manual predictions initially differed from simulation outputs.
2. Verification Scope Audit: Explain why `reset_dut` executes inside the `for` loop, define initial state at vector application, and identify 1 core behavior directly tested alongside 1 untested boundary condition.
3. Subsequent Experiment Design: Propose 2 consecutive input vectors designed to trigger and observe carry propagation across repeated additions, calculating stepped expected values after accumulation 1 and accumulation 2 (experimental design required; RTL implementation optional).
4. Chapter Key Takeaways: Summarize the core hardware mechanisms from CH06–CH10 in one sentence each.

## 7. Submission Checklist

- Run `make clean` followed by `make package`, confirming clean completion with `PASS ../verilog_check2_<id>.zip`.
- Verify the generated zip contains `student.mk`, `predictions.vh`, `tb_boundary.v`, `report.md`, `integrity.txt`, and `evidence/`.
- Verify `evidence/` contains `env.txt`, `tutorial_ch06.log`–`tutorial_ch10.log`, `probe_ch06.log`–`probe_ch10.log`, `boundary.log`, and `manifest.txt`.
- Confirm `boundary.log` displays `REQUIRED` inputs at rows 10 and 11, and the final PASS banner reports 12 vectors.
- Upload target and deadlines follow LMS course announcements.
