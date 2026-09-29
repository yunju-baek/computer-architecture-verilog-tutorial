// Check 1 Expected Value Configuration File. 'make test' compares these values against simulation outputs.
//
// Instructions:
//   1. Run 'make show-inputs' to view test inputs derived from your student ID.
//   2. Read the referenced source files in the tutorial and manually calculate outputs.
//   3. Replace the 'x' placeholders below with your calculated values. Retain bit-width specifiers.
//   4. Run 'make test'. UNANSWERED indicates unassigned 'x', while FAIL indicates a calculation mismatch.
//
// Notation examples: 4'b1010  7'h33  5'd9  1'b1  32'h0000_1234  -3 (for decimal fields)

// CH01  ex02_inverter: y = ~a
`define P_CH01_Y               4'bx

// CH02  ex04_select: Instruction word bitfields
`define P_CH02_OPCODE          7'bx
`define P_CH02_RD              5'bx
`define P_CH02_FUNCT3          3'bx
`define P_CH02_RS1             5'bx
`define P_CH02_RS2             5'bx
`define P_CH02_FUNCT7          7'bx

// CH03  ex02_width_rules: a + b stored in 4-bit and 5-bit registers, carry-out, signed interpretation of a (decimal)
`define P_CH03_NARROW_SUM      4'bx
`define P_CH03_WIDE_SUM        5'bx
`define P_CH03_CARRY           1'bx
`define P_CH03_A_SIGNED        32'bx

// CH04  with_default decoder outputs (4 signals) and ex01_mux4 output
`define P_CH04_ALU_SELECT      2'bx
`define P_CH04_WRITE_ENABLE    1'bx
`define P_CH04_MEMORY_READ     1'bx
`define P_CH04_ILLEGAL         1'bx
`define P_CH04_MUX_Y           8'bx

// CH05  ex03_control step-by-step state, shift_nonblocking {q0,q1,q2}
`define P_CH05_AFTER_LOAD        32'bx
`define P_CH05_AFTER_ENABLE      32'bx
`define P_CH05_AFTER_RESET_LOAD  32'bx
`define P_CH05_SHIFT_Q0Q1Q2      3'bx
