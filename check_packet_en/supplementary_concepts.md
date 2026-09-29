# Supplementary Concept Review

Review the following concepts alongside tutorial source files based on the Session 1 setup and execution walkthrough.

## Signed Numbers

- The presence of a `signed` declaration dictates how a bit pattern evaluates as an integer.
- A 4-bit two's complement signed representation covers values from -8 to 7.
- Check bit widths and signedness attributes of both operands during comparison and arithmetic operations.
- The `$signed` system function explicitly treats an unsigned bit pattern as signed.

Source reference: https://github.com/yunju-baek/computer-architecture-verilog-tutorial/blob/da729b32434a43784bd36b06db16ff8a2c4bbe14/tutorial/ch03/ex03_signed.v

## Operators and Shifts

- `&` represents bitwise AND, whereas `&&` evaluates scalar logical truth across operands.
- `>>` performs logical right shift, padding high-order bits with zeros.
- Applying `>>>` to a signed 4-bit signal performs arithmetic right shift, replicating the sign bit into high-order positions.
- In the final lecture slide example, signal `s` is declared as a signed 4-bit wire.

Source reference: https://github.com/yunju-baek/computer-architecture-verilog-tutorial/blob/da729b32434a43784bd36b06db16ff8a2c4bbe14/tutorial/ch03/ex04_shift.v

## Combinational Logic Review

- Audit every conditional branch path to guarantee complete assignment for each output signal.
- Incomplete assignment across branch paths inside combinational blocks infers unwanted transparent latches.
- The `bad01_latch` module demonstrates latch synthesis caused by missing branch defaults.
- Document exact source code lines and triggering input conditions in your report.

Source reference: https://github.com/yunju-baek/computer-architecture-verilog-tutorial/blob/da729b32434a43784bd36b06db16ff8a2c4bbe14/tutorial/ch04/README.md
