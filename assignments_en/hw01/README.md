# HW01: Function calls and architectural state

Implement an RV32I array sum and explain how calls change the PC, registers, and stack. Complete the assembly, explain four trace events, write two boundary tests, and test the effect of omitting the return-address restore.

## Provided files and student work

| File | Role |
|---|---|
| `programs/state_contract.c` | Provided behavioral reference; keep this file unchanged |
| `programs/state_contract.s` | Complete `add_word` and `sum_array` |
| `tests/test_student_cases.py` | Complete the empty-array and wraparound tests |
| `report.md` | Complete four sections using your execution results |
| `integrity.txt` | Record references, tools, and your verification |
| `tools/rv32i.py`, `scripts/` | Provided simulator and experiment tools |

Required tools: Python 3.11 or later and Make. A C compiler supports the optional reference check. Check the C and assembly implementations separately. Generate the trace with the supplied assembly state simulator.

## 1. Implement the assembly

- `add_word` adds `a0` and `a1` modulo 2^32 and returns the result in `a0`.
- `sum_array` receives the array address in `a0` and element count in `a1`. Call `add_word` for each element.
- Preserve the pointer, count, and accumulated value across nested calls. Restore `sp` and any used `s0`–`s2` registers before returning.
- Save the incoming `ra` on the stack and restore it with `lw ra, offset(sp)` before returning. Each call overwrites `ra`; a function making nested calls saves its own return address.
- Retain the supplied `main`, `values`, `result`, and function labels. The default array is `{5, -2, 9, -7}` and its expected sum is `5`.

## 2. Explain four trace events

Run `make evidence`. Select one row each for `call`, an array load `lw`, a stack store `sw`, and `ret` from `evidence/architectural_trace.csv`. For each row, record `seq`, the current PC, the state and value that changed, and the next PC.

Choose the call to `add_word` inside `sum_array` and the return from `sum_array` to `main`. Explain the link between the return address written by the call and the next PC selected by the return. `seq` counts executed instructions; hardware clock cycles belong to a separate timing model.

## 3. Write two boundary tests

Complete the two methods in `tests/test_student_cases.py`. The supplied `run_sum` helper returns register state and an instruction trace.

| Test | Input | Assertions |
|---|---|---|
| `test_empty_array` | `[]` | Predicted `a0` and restored `sp=0x800` |
| `test_word_wraparound` | `[0xffffffff, 1]` | Predicted modulo-2^32 `a0` and restored `sp` |

Record predictions before running the tests. Each test must assert both `a0` and `sp`. The public and instructor checks cover additional arrays, including mixed signs.

## 4. Omit ra restoration and compare return PCs

First write your prediction in report section 4:

- The value left in `ra` before the final `ret` in `sum_array`
- The next PC and the instruction at that address
- The likely effect on subsequent execution

Then run `make ra-experiment`. The tool creates a separate assembly file that replaces one stack load restoring `ra` with a same-size `nop`. Labels and instruction addresses stay fixed. Execution stops immediately after the selected return, and the normal submitted source stays intact.

If your source has multiple restore instructions, select the relevant line in `sum_array` with `make ra-experiment RESTORE_LINE=<line>`. Record `RESTORE_LINE = <line>` in the Makefile so the same selection applies during instructor reruns. If your implementation has one restore instruction, use the default command.

| Generated file | Content |
|---|---|
| `evidence/ra_experiment/normal_trace.csv` | Full normal execution |
| `evidence/ra_experiment/ra_omitted.s` | Separate source with one restore replaced by `nop` |
| `evidence/ra_experiment/ra_omitted_trace.csv` | Changed execution through the selected return |
| `evidence/ra_experiment/comparison.json` | Normal and changed return PCs |

Compare your prediction with the observed next PC. Explain the later effect using the instruction and state at that destination. Keep the generated source as experiment evidence.

## Run sequence

```bash
make setup-check
make test
make evidence
# Record the prediction in report section 4 before this command.
make ra-experiment
```

`make test` runs public assembly checks and the two student tests. `make test-c` optionally executes the provided C reference.

## Submission

Submit the assignment folder containing:

- Completed `programs/state_contract.s`
- Completed `tests/test_student_cases.py`
- Four sections in `report.md` and your `integrity.txt`
- The `evidence/` output from `make evidence` and `make ra-experiment`

Retain the provided C reference, tools, and public tests. Assessment covers assembly behavior and state preservation, four trace explanations, two boundary tests, and prediction, observation, and explanation of the return-address experiment. Machine-code field analysis and additional C programming are optional study activities.
