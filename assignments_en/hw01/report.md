# HW01 report: Function calls and state changes

Complete four sections using your code and execution results. Cite trace events by `seq` and source locations by `file:line`. Record tool use in `integrity.txt`.

## 1. Assembly implementation

| Item | Source location and explanation |
|---|---|
| `add_word` arguments and result | [Fill in] |
| `sum_array` loop and nested call | [Fill in] |
| Saved and restored `ra`, `sp`, and saved registers | [Fill in] |
| `make test` result | [Fill in] |

## 2. Four state transitions

| Event | `seq` | Current PC | Instruction | Changed state and value | Next PC |
|---|---:|---:|---|---|---:|
| `call` inside `sum_array` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Array load `lw` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Stack store `sw` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Return from `sum_array` | [Fill in] | [Fill in] | [Fill in] | [Fill in] | [Fill in] |

In two or three sentences, explain how the return address recorded by the call determines the next PC selected by the return.

[Fill in]

## 3. Boundary tests

Record predictions before execution. Assert both `a0` and `sp` in each test.

| Input | Predicted `a0` | Observed `a0` | Restored `sp` | Test method |
|---|---:|---:|---:|---|
| `[]` | [Fill in] | [Fill in] | [Fill in] | `test_empty_array` |
| `[0xffffffff, 1]` | [Fill in] | [Fill in] | [Fill in] | `test_word_wraparound` |

Reason for wraparound: [Fill in]

## 4. Omitted ra restore: prediction and observation

**Before execution**

- Source line and address of the `lw ra, offset(sp)` to replace: [Fill in]
- `ra` before the final `ret`, next PC, and instruction at that address: [Fill in]
- Predicted effect on subsequent execution and its cause: [Fill in]

Record the prediction, then run `make ra-experiment`.

| Item | Normal execution | Omitted ra restore |
|---|---|---|
| Compared return `seq` and PC | [Fill in] | [Fill in] |
| Next PC after the return | [Fill in] | [Fill in] |
| Instruction at that destination | [Fill in] | [Fill in] |

In two or three sentences, compare the prediction with the observation and explain any discrepancy. The tool stops recording immediately after this return. Infer later effects from the destination instruction and architectural state.

[Fill in]
