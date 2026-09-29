// Check 2 Expected Value Configuration File. 'make test' compares these values against simulation outputs.
//
// Instructions:
//   1. Run 'make show-inputs' to view test inputs derived from your student ID.
//   2. Read the referenced source files in the tutorial and manually calculate outputs.
//   3. Replace the 'x' placeholders below with your calculated values. Retain bit-width specifiers.
//   4. Run 'make test'. UNANSWERED indicates unassigned 'x', while FAIL indicates a calculation mismatch.
//
// Notation examples: 8'h3c  16'h1234  1'b1  2'd3  5 (for decimal fields)

// CH06  ex03_generate WIDTH=8: sum, carry_out, mid-carry from lower 4 bits
`define P_CH06_SUM             8'bx
`define P_CH06_CARRY_OUT       1'bx
`define P_CH06_MID_CARRY       1'bx

// CH07  Memory read evaluation timing (3 signals) and FSM states (2 signals)
`define P_CH07_COMB_AFTER_2    8'bx
`define P_CH07_SYNC_AFTER_2    8'bx
`define P_CH07_SYNC_AFTER_3    8'bx
`define P_CH07_DETECT_COUNT    32'bx    // Decimal. Number of times detected=1 across 8 clock edges
`define P_CH07_FINAL_STATE     2'bx     // IDLE=0 SAW_ONE=1 SAW_TWO=2 SAW_MANY=3

// CH08  Accumulator outputs after sequentially adding x1 and x2
`define P_CH08_TOTAL1          16'bx
`define P_CH08_TOTAL2          16'bx
`define P_CH08_ZERO2           1'bx
`define P_CH08_CARRY2          1'bx

// CH09  ex01_synthesizable WIDTH=8: result and is_zero after 3 operation stages
`define P_CH09_RESULT          8'bx
`define P_CH09_IS_ZERO         1'bx

// CH10  mux_systemverilog output, dff_systemverilog q after edge 1 and edge 2
`define P_CH10_MUX_Y           8'bx
`define P_CH10_Q_AFTER_1       8'bx
`define P_CH10_Q_AFTER_2       8'bx
