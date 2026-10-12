# HW01 report: Function calls and state changes

Complete four sections using your own code and the evidence generated with your student ID. Cite trace rows by `seq` and source locations by `file:line`. Write addresses and values in `0x` hexadecimal, as in the trace. Keep the table rows in order and replace every fill-in mark with your answer. Record tool use in `integrity.txt`.

## 1. Assembly implementation

| Item | Source location and explanation |
|---|---|
| `add_word` arguments and result | [Fill in] |
| `sum_array` loop and nested call | [Fill in] |
| Saved and restored `ra`, `sp`, and saved registers | [Fill in] |
| `make test` result (passed/total) | [Fill in] |

## 2. Four state changes

Check your input with `make my-input`, write the predicted sum first, then run `make evidence`.

| Item | Value |
|---|---|
| Your input `values` (decimal) | [Fill in] |
| Predicted sum before the run (`0x` hexadecimal) | [Fill in] |
| Observed `result` (`observed_result` in `evidence/run_info.json`) | [Fill in] |

Choose one row of `evidence/architectural_trace.csv` for each event. For the changed state, write the register or memory address together with its new value.

| Event | `seq` | Current `PC` | Instruction | Changed state and value | Next `PC` |
|---|---:|---:|---|---|---:|
| `call` to `add_word` inside `sum_array` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Array element load `lw` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Stack store `sw` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| `ret` from `sum_array` to `main` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |

In two or three sentences, explain how the return address written by `call` determines the next `PC` chosen by `ret`.

[Fill in]

## 3. Boundary tests

Write the expected values before running the tests. Both tests check `a0` and `sp` with assertions.

| Input | Expected `a0` before the run | Observed `a0` | `sp` after the run | Test method |
|---|---:|---:|---:|---|
| `[]` | [Fill in] | [Fill in] | [Fill in] | `test_empty_array` |
| `[0xffffffff, 1]` | [Fill in] | [Fill in] | [Fill in] | `test_word_wraparound` |

Why wraparound occurs: [Fill in]

## 4. Omitting the ra restore: prediction and observation

Write the prediction first.

- Source line and instruction address of the `lw ra, offset(sp)` to replace: [Fill in]
- `ra` just before the last `ret`, the next `PC`, and the instruction at that address: [Fill in]
- Expected effect on later execution, with the reason: [Fill in]

After recording the prediction, run `make ra-experiment` and fill the table from `evidence/ra_experiment/comparison.json`.

| Comparison | Normal run | Run without the ra restore |
|---|---|---|
| `seq` and `PC` of the compared `ret` | [Fill in] | [Fill in] |
| Next `PC` after `ret` | [Fill in] | [Fill in] |
| Instruction at that address | [Fill in] | [Fill in] |

Compare the prediction with the observation. If they differ, explain the cause in two or three sentences. The tool records execution up to the instruction right after the selected `ret`, so explain later effects from the destination instruction and the register state.

[Fill in]
