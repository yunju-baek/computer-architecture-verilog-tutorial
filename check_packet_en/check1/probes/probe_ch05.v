// Check 1-5. CH05 Sequential Logic. Predict control priorities and non-blocking shift register states.
// Target: tutorial/ch05/ex03_control.v, tutorial/ch05/ex02_blocking.v (shift_nonblocking)
//
// Inputs update on clock falling edge; states are sampled at #1 after clock rising edge.
`timescale 1ns/1ps

module probe_ch05;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3;
  reg         clk = 1'b0;

  // ex03_control
  reg         reset, load, enable;
  reg  [31:0] load_value;
  wire [31:0] state;
  reg  [31:0] after_load, after_enable, after_reset_load;
  integer     k, i;

  // shift_nonblocking
  reg         d;
  wire        q0, q1, q2;
  reg  [2:0]  bits;
  reg  [2:0]  shift_q;

  integer     fails;

  ex03_control      ctrl (.clk(clk), .reset(reset), .load(load), .enable(enable),
                          .load_value(load_value), .state(state));
  shift_nonblocking shift(.clk(clk), .d(d), .q0(q0), .q1(q1), .q2(q2));

  always #5 clk = ~clk;

  task step;                 // Advance one clock rising edge and hold after #1
    begin
      @(posedge clk); #1;
    end
  endtask

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0500
    s1 = lcg_next(sid ^ 32'h5A5A0500);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    load_value = {s1[31:2], 2'b00};        // Word-aligned 32-bit value
    k          = s2[31:30] + 1;            // Number of rising edges to assert enable (1..4)
    bits       = s3[31:29];                // 3 bits shifted into register

    $display("=== probe_ch05 STUDENT_ID=%0d ===", sid);
    $display("INPUT ex03_control: load_value=%h  enable edge count k=%0d", load_value, k);
    $display("      Sequence: [1] reset=1  [2] load=1,enable=1  [3] enable=1 x k  [4] reset=1,load=1,enable=1");
    $display("INPUT shift_nonblocking: d sequence = %b, %b, %b (3 edges)", bits[2], bits[1], bits[0]);

    // ---- ex03_control ----
    @(negedge clk);
    reset = 1'b1; load = 1'b0; enable = 1'b0;
    step;                                              // [1] state = 0

    @(negedge clk);
    reset = 1'b0; load = 1'b1; enable = 1'b1;
    step;                                              // [2] load and enable asserted simultaneously
    after_load = state;

    @(negedge clk);
    load = 1'b0; enable = 1'b1;
    for (i = 0; i < k; i = i + 1) step;                // [3] enable only for k cycles
    after_enable = state;

    @(negedge clk);
    reset = 1'b1; load = 1'b1; enable = 1'b1;
    step;                                              // [4] all three inputs asserted simultaneously
    after_reset_load = state;

    @(negedge clk);
    reset = 1'b0; load = 1'b0; enable = 1'b0;

    // ---- shift_nonblocking ----
    @(negedge clk); d = bits[2]; step;
    @(negedge clk); d = bits[1]; step;
    @(negedge clk); d = bits[0]; step;
    shift_q = {q0, q1, q2};

    `CHECK("CH05_AFTER_LOAD",       `P_CH05_AFTER_LOAD,       after_load)
    `CHECK("CH05_AFTER_ENABLE",     `P_CH05_AFTER_ENABLE,     after_enable)
    `CHECK("CH05_AFTER_RESET_LOAD", `P_CH05_AFTER_RESET_LOAD, after_reset_load)
    `CHECK("CH05_SHIFT_Q0Q1Q2",     `P_CH05_SHIFT_Q0Q1Q2,     shift_q)
    `FINISH_CHECK("ch05", sid)
  end
endmodule
