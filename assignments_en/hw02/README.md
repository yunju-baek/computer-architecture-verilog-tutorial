# HW02: Processor building blocks

Implement the ALU, PC, register file, immediate generator, and decoder. Verify each module with waveforms. Reuse the ALU, register file, immediate generator, and decoder in HW03 with the same ports.

## 1. Implementation requirements

| File | Student work | Required behavior |
|---|---|---|
| `rtl/alu.v` | Select `result` | Ten 32-bit operations, default result zero |
| `rtl/pc_counter.v` | Update state | reset > load > enable > hold |
| `rtl/regfile.v` | Implement register storage and ports | Rising-edge write, two combinational reads, x0=0 |
| `rtl/rv32i_immgen.v` | Assemble immediate bits | I, S, B, U, J formats |
| `rtl/rv32i_decode.v` | Generate control signals | Keep the supplied ports, constants, and instruction subset |

ALU codes are `0:ADD, 1:SUB, 2:AND, 3:OR, 4:XOR, 5:SLL, 6:SRL, 7:SRA, 8:SLT, 9:SLTU`. Use `b[4:0]` for shifts. SRA and SLT interpret signed operands. Retain the supplied carry, overflow, and zero logic. Study the difference between carry and overflow in the classroom check questions.

Assign default outputs for combinational logic and use nonblocking assignments for clocked state. Keep module names and ports unchanged. Read the public testbenches for register-file behavior and supported instructions.

## 2. Execution and student tests

```bash
make setup-check
make test-alu
make test-pc
make test-regfile
make test-decode
make student-test
make evidence
```

Complete at least six checks in `tests/tb_student_blocks.v`, covering PC priority, register writes and x0, immediate assembly, and decode. Predict results before execution and compare them with assertions. Use these same cases for the changed-condition discussion.

Public ALU tests cover all ten operations, low-five-bit shift amounts, signed boundaries, and default outputs. Choose SRA and SLT/SLTU cases from the waveforms and explain their results.

## 3. Report and submission

Complete the four sections of [report.md](report.md): module interfaces and behavior, representative waveforms, student tests, and reuse in HW03. Cite input/output values and clock edges.

Submit the five files in `rtl/`, `tests/tb_student_blocks.v`, `report.md`, `integrity.txt`, and `evidence/`. Evidence contains `alu.vcd`, `pc.vcd`, `regfile.vcd`, `decode.vcd`, and `student_blocks.vcd`. Retain provided tools and public tests.

## 4. Reuse and optional study

Reuse `alu.v`, `regfile.v`, `rv32i_immgen.v`, and `rv32i_decode.v` in HW03. The PC module teaches state control; the HW03 core implements its own PC update. The HW03 release will include the module import procedure.

Consult ch02–ch05 and ch07–ch08 of the [Verilog tutorial](../../tutorial_en/README.md). The [arithmetic reference](../../tutorial_en/arithmetic_reference/README.md) supplies complete Python code. Python implementation, dot-product analysis, and accumulator study are optional. Submitting this work is also optional.

See the [interface contract](CONTRACT.md) for control codes and the supported subset.
