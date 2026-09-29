// Check 1-1. CH01 First Module. Predict output of 4-bit inverter.
// Target: tutorial/ch01/ex02_inverter.v
`timescale 1ns/1ps

module probe_ch01;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s;
  reg  [3:0]  a;
  wire [3:0]  y;
  integer     fails;

  ex02_inverter dut(.a(a), .y(y));

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0100
    s = lcg_next(sid ^ 32'h5A5A0100);
    a = s[31:28];

    $display("=== probe_ch01 STUDENT_ID=%0d ===", sid);
    $display("INPUT a=%b (%0d)", a, a);
    #1;

    `CHECK("CH01_Y", `P_CH01_Y, y)
    `FINISH_CHECK("ch01", sid)
  end
endmodule
