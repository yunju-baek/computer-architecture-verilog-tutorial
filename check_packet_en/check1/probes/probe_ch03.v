// Check 1-3. CH03 Bit-Width Rules. Predict addition of two 4-bit values stored in 4-bit and 5-bit registers.
// Target: Rules 1 and 2 from tutorial/ch03/ex02_width_rules.v and signed interpretation from ex03_signed.v
`timescale 1ns/1ps

module probe_ch03;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2;
  reg  [3:0]  a, b;
  reg  [3:0]  narrow_sum;
  reg  [4:0]  wide_sum;
  reg         carry_bit;
  integer     a_signed;
  integer     fails;

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0300
    s1 = lcg_next(sid ^ 32'h5A5A0300);
    s2 = lcg_next(s1);
    a = s1[31:28];
    b = s2[31:28];

    $display("=== probe_ch03 STUDENT_ID=%0d ===", sid);
    $display("INPUT a=%b (%0d)  b=%b (%0d)  Both values evaluated as 4-bit unsigned integers", a, a, b, b);

    // Rule 1. Left-hand side bit-width determines operation bit-width.
    narrow_sum = a + b;
    // Rule 2. Carry-out captured by extending evaluation bit-width.
    wide_sum   = {1'b0, a} + {1'b0, b};
    carry_bit  = wide_sum[4];
    // Signed interpretation. Bit pattern 'a' evaluated as 4-bit signed integer.
    a_signed   = $signed(a);
    #1;

    `CHECK ("CH03_NARROW_SUM", `P_CH03_NARROW_SUM, narrow_sum)
    `CHECK ("CH03_WIDE_SUM",   `P_CH03_WIDE_SUM,   wide_sum)
    `CHECK ("CH03_CARRY",      `P_CH03_CARRY,      carry_bit)
    `CHECKD("CH03_A_SIGNED",   `P_CH03_A_SIGNED,   a_signed)
    `FINISH_CHECK("ch03", sid)
  end
endmodule
