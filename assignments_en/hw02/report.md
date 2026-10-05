# HW02 report

Identify source locations with `file:line`. Cite VCD signal names, timestamps, and case_id values for waveform evidence. Record references and tool use in `integrity.txt`.

## 1. Module interfaces and behavior

| Module | Inputs and outputs | State or combinational behavior | Source location |
|---|---|---|---|
| ALU | [Fill in] | [Fill in] | [Fill in] |
| PC | [Fill in] | [Fill in] | [Fill in] |
| Register file | [Fill in] | [Fill in] | [Fill in] |
| ImmGen | [Fill in] | [Fill in] | [Fill in] |
| Decoder | [Fill in] | [Fill in] | [Fill in] |

## 2. Representative waveforms

| Case | Inputs and controls | Prediction | Observation and location | Explanation |
|---|---|---|---|---|
| ALU SRA | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| ALU SLT/SLTU | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| PC priority | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Register write and x0 | [Fill in] | [Fill in] | [Fill in] | [Fill in] |
| Negative immediate and decode | [Fill in] | [Fill in] | [Fill in] | [Fill in] |

## 3. Student tests

Record six testbench checks in the table. For one case, explain the condition you changed and why it produced the observed result in two or three sentences.

| Check | Input and prediction | Observation | Assertion location |
|---|---|---|---|
| 1 | [Fill in] | [Fill in] | [Fill in] |
| 2 | [Fill in] | [Fill in] | [Fill in] |
| 3 | [Fill in] | [Fill in] | [Fill in] |
| 4 | [Fill in] | [Fill in] | [Fill in] |
| 5 | [Fill in] | [Fill in] | [Fill in] |
| 6 | [Fill in] | [Fill in] | [Fill in] |

Changed condition: [Fill in]

## 4. Reuse check

- Results of `make test` and `make evidence`: [Fill in]
- Four reusable modules and compatible ports for HW03: [Fill in]
- One defect and the evidence for your correction. If the first implementation passed, give the boundary-test evidence: [Fill in]
