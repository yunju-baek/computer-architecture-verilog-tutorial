# Assignment 2: Processor building blocks

Implement and test the ALU, PC, register file, immediate generator, and decoder. Use `assignments_en/hw02/` in the student package. Submit through the corresponding LMS assignment entry by the deadline shown there.

## Required work

1. Complete the five modules in `rtl/`. Implement ALU result selection for ten operations. Use the supplied carry, overflow, and zero logic.
2. Implement PC priority `reset > load > enable > hold`, rising-edge register writes, combinational reads, and x0 behavior. Follow `CONTRACT.md` for immediate formats and supported decoder instructions.
3. Write at least six checks in `tests/tb_student_blocks.v`. Cover PC priority, register writes and x0, immediate generation, and decode. Compare predicted values with assertions.
4. Complete four report sections: module interfaces and behavior, representative waveforms, student tests, and reuse checks. Explain SRA and SLT/SLTU results and the effect of changing a condition in one student test.

## Run

Use Python 3.11 or later, GNU Make, and Icarus Verilog. Run these commands in `assignments_en/hw02/`.

```bash
make setup-check
make test-alu
make test-pc
make test-regfile
make test-decode
make student-test
make evidence
```

## Submission and grading

Submit your completed `hw02` folder with the five files in `rtl/`, `tests/tb_student_blocks.v`, `report.md`, `integrity.txt`, and `evidence/`. Include `alu.vcd`, `pc.vcd`, `regfile.vcd`, `decode.vcd`, and `student_blocks.vcd`. Keep the supplied tools and public tests.

The assignment is worth 100 points: implementation 50, verification 30, report 20. Connect predicted values to observations in the waveforms. Record your references, tools, and verification work in `integrity.txt`.

Reuse the completed ALU, register file, immediate generator, and decoder in Assignment 3 with the same ports. The PC module is a state-control exercise for this assignment. Python arithmetic, dot-product analysis, and accumulator study are optional.
