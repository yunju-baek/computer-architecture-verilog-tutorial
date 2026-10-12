# HW01: Function calls and architectural state

Implement an RV32I array sum in assembly and explain how a call and its return change the `PC`, registers, and stack. The work has four activities: the assembly implementation, state-change tracing, boundary tests, and an experiment that omits the `ra` restore. Each student's trace is generated from an input derived from the student ID, so report values differ between students.

## 1. Setup and student ID

You need Python 3.11 or later and GNU Make. A C compiler is used only by the optional `make test-c`.

1. Open `student_id.txt` and write your student ID, digits only, on the line below the `#` comment.
2. Run `make setup-check` to check the Python version.
3. Run `make my-input` to see your input. It prints three items.

| Item | Meaning |
|---|---|
| `values_decimal`, `values_hex` | The 4 elements that `make evidence` places in `values` for `main` |
| `initial_sp` | `sp` when `main` starts |
| `initial_saved` | `s0`–`s2` when `main` starts; they must hold the same values after `sum_array` returns |

The same student ID always gives the same input. The public checks (`make test`) use the default input `{5, -2, 9, -7}` with expected sum `5`.

## 2. Files you write and files provided

| Kind | File | Role |
|---|---|---|
| Student work | `programs/state_contract.s` | Complete `add_word` and `sum_array` |
| Student work | `tests/test_student_cases.py` | Complete the empty-array and wraparound tests |
| Student work | `report.md` | Four-section report |
| Student work | `integrity.txt` | Sources and tools used, and your own verification |
| Student work | `student_id.txt` | Your student ID |
| Provided, read only | `programs/state_contract.c` | Behavioral reference for the array sum and modulo-2^32 addition |
| Provided, read only | `tools/rv32i.py` | Assembler and architectural-state simulator |
| Provided, read only | `scripts/`, `tests/test_public_state.py`, `Makefile` | Student input, evidence, `ra` experiment, submission ZIP, public checks |

Use the provided files as they are. The instructor replaces them with the reference copies before rerunning a submission. In the `Makefile`, the only line you may set is `RESTORE_LINE`.

## 3. Workflow

| Step | Task | Command | Record in |
|---:|---|---|---|
| 1 | Write your student ID and check the setup | `make setup-check`, `make my-input` | — |
| 2 | Implement `add_word` and `sum_array` | `make test-assembly` | Report section 1 |
| 3 | Write the two boundary tests (record expected values first) | `make test` | Report section 3 |
| 4 | Record the predicted sum, then generate the trace | `make evidence` | Report section 2 |
| 5 | Predict the effect of omitting the `ra` restore, then run the experiment | `make ra-experiment` | Report section 4 |
| 6 | Complete `integrity.txt` and build the submission ZIP | `make package` | Upload to the LMS |

`make evidence` and `make ra-experiment` also run on unfinished code. They print `WARN` when a result differs from the expected value, so the trace doubles as a debugging aid. After changing the assembly, repeat steps 4–6.

## 4. Activity requirements

### 4.1 Assembly implementation

- `add_word` returns the 32-bit sum of `a0` and `a1` in `a0`.
- `sum_array` takes the array address in `a0` and the element count in `a1` and returns the sum. It calls `add_word` once per element.
- Keep the pointer, count, and running sum across nested calls. On return, `sp` and every used `s0`–`s2` hold their entry values.
- `sum_array` saves `ra` on the stack at entry and restores it with `lw ra, offset(sp)` before returning. Every call overwrites `ra`, so a function that makes nested calls keeps its own return address.
- Keep the provided `main`, `values` (4 elements), `result`, and function labels.

### 4.2 Four state changes

From `evidence/architectural_trace.csv`, choose one row each for `call`, an array-element `lw`, a stack `sw`, and `ret`. For `call`, use the row in `sum_array` that calls `add_word`. For `ret`, use the row where `sum_array` returns to `main`. Record the `seq`, current `PC`, instruction, changed state and value, and next `PC` in report section 2.

The trace columns are `seq`, `pc`, `word`, `asm`, `rd`, `rd_value`, `mem_addr`, `mem_value`, `next_pc`, and `sp`. Addresses and values are written as 8-digit `0x` hexadecimal. `seq` is the instruction order; hardware clock cycles are studied with a separate model. The input and final state are in `evidence/run_info.json` and `evidence/final_state.json`.

### 4.3 Two boundary tests

Complete the two methods in `tests/test_student_cases.py`. The provided `run_sum` returns the execution result (`result.registers`, `result.trace`).

| Test | Input | Check with assertions |
|---|---|---|
| `test_empty_array` | `[]` | `a0` after the run and restoration of the entry `sp=0x800` |
| `test_word_wraparound` | `[0xffffffff, 1]` | Modulo-2^32 `a0` and `sp` restoration |

A good test passes on a correct implementation and fails on an implementation with a wrong `a0` and on one that leaves `sp` changed. Record the expected values in report section 3 before running and compare them with the observed values.

### 4.4 ra-restore omission experiment

Record three predictions in report section 4 first:

- the value left in `ra` just before the last `ret` of `sum_array`
- the next `PC` after that `ret` and the instruction at that address
- the effect on later execution

Then run `make ra-experiment`. The tool builds a separate copy in which one `lw` that restores `ra` becomes a `nop` of the same size, and records execution up to the instruction right after that `ret`. Instruction addresses and labels stay the same, and your submitted source stays unchanged.

| Output | Role |
|---|---|
| `evidence/ra_experiment/normal_trace.csv` | Full run of the normal program |
| `evidence/ra_experiment/ra_omitted.s` | Copy with one restore replaced by `nop` |
| `evidence/ra_experiment/ra_omitted_trace.csv` | Run of the changed copy up to that `ret` |
| `evidence/ra_experiment/comparison.json` | Return `PC` and destination instruction of both runs |

If `sum_array` contains several `lw ra, offset(sp)` lines, the tool prints their source line numbers. Pick the `sum_array` restore and change the `# RESTORE_LINE =` line in the `Makefile` to `RESTORE_LINE = <line>`. The instructor rerun uses the same value.

## 5. Supported assembly syntax

| Kind | Instructions |
|---|---|
| R type | `add sub sll slt sltu xor srl sra or and` |
| I type | `addi slti sltiu xori ori andi slli srli srai lw jalr` |
| S, B, J types | `sw beq bne blt bge bltu bgeu jal ebreak` |
| Pseudo-instructions | `nop mv li la neg not seqz snez j jr call ret beqz bnez bltz bgez blez bgtz bgt ble bgtu bleu` |
| Directives | `.data .text .globl .word` |

The `li` immediate is limited to -2048..2047. Comments start with `#`. Every instruction assembles to a real 32-bit RV32I encoding.

## 6. Submission

1. Rerun `make evidence` and `make ra-experiment` with your final source.
2. Run `make package`. It creates `submit/hw01_<student ID>.zip`.
3. Read the `WARN` lines, fix what you can, and run `make package` again. The ZIP is created for unfinished work too, and partial work earns partial credit.
4. Upload `submit/hw01_<student ID>.zip`, and only that file, to the HW01 entry on the LMS.

The ZIP contains the whole assignment folder except `build/`, `submit/`, and caches. `make clean` removes only build files and caches. Use `make clean-evidence` to remove evidence.

## 7. Grading

| Area | Points | How it is checked |
|---|---:|---|
| Implementation: specified behavior | 30 | `add_word`, `result` for the default input, sums of several arrays, one `add_word` call per element |
| Implementation: boundaries and calling convention | 20 | Empty array, wraparound, `sp` and `s0`–`s2` restoration, `ra` saved and restored on the stack |
| Verification: student tests | 20 | Per test: passes on a correct implementation 4, detects a wrong `a0` 3, detects a wrong `sp` 3 |
| Verification: evidence | 10 | Submitted evidence matches evidence regenerated with your student ID (normal trace 5, `ra` experiment 5) |
| Report | 20 | 5 per section: links between code locations, your own trace values, predictions and observations, and causes |

The instructor replaces the provided files with reference copies and regenerates all evidence from your assembly and student ID. Evidence generated with another student ID, report values that disagree with your own trace, and report text shared between submissions are marked for individual review by the instructor. Machine-code field analysis and an extra C implementation are optional study.
