// Check 2-3. CH08 Testbench. Predict outputs after sequentially adding two values in accumulator,
// and derive two boundary test values to extend tb_boundary.v.
// Target: tutorial/ch08/ex01_dut.v
//
// Inputs update on clock falling edge; states sample at #1 after clock rising edge. Reset is 0 between additions.
`timescale 1ns/1ps

module probe_ch08;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3, s4;
  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;
  reg  [15:0] x1, x2;
  reg  [15:0] total1, total2;
  reg         zero2, carry2;

  // 2 values to add to tb_boundary.v
  reg  [15:0] b10, b11;
  reg  [15:0] existing [0:9];
  integer     j, dup, fh;

  integer     fails;

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk); #1;
    end
  endtask

  // Avoid collisions with original 10 boundary values in tb_ex03.v by incrementing.
  task avoid_existing;
    inout [15:0] value;
    input [15:0] other;
    begin
      dup = 1;
      while (dup) begin
        dup = (value == other);
        for (j = 0; j < 10; j = j + 1)
          if (value == existing[j]) dup = 1;
        if (dup) value = value + 16'd1;
      end
    end
  endtask

  initial begin
    fails = 0;
    read_student_id(sid);

    existing[0] = 16'h0000; existing[1] = 16'h0001; existing[2] = 16'h7fff;
    existing[3] = 16'h8000; existing[4] = 16'hffff; existing[5] = 16'hfffe;
    existing[6] = 16'h00ff; existing[7] = 16'hff00; existing[8] = 16'h5555;
    existing[9] = 16'haaaa;

    // Input derivation: salt 0x5A5A0800
    s1 = lcg_next(sid ^ 32'h5A5A0800);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    s4 = lcg_next(s3);
    x1  = {1'b1, s1[30:16]};             // Force MSB=1 to create carry generation potential
    x2  = s2[31:16];
    b10 = s3[31:16];
    b11 = s4[31:16];
    avoid_existing(b10, 16'hffff);       // Prevent collision with existing 10 vectors
    avoid_existing(b11, b10);            // Prevent collision with b10

    $display("=== probe_ch08 STUDENT_ID=%0d ===", sid);
    $display("INPUT accumulator: After 1 reset edge, assert enable=1 with addend x1=%h, then next edge x2=%h", x1, x2);
    $display("      TOTAL1 is total after adding x1; TOTAL2/ZERO2/CARRY2 are sampled after adding x2");
    $display("REQUIRED tb_boundary.v: boundary_values[10] = 16'h%h  boundary_values[11] = 16'h%h", b10, b11);

    // File consumed by boundary-test; build/ directory created by Makefile.
    fh = $fopen("build/required_values.txt", "w");
    if (fh != 0) begin
      $fwrite(fh, "%h\n%h\n", b10, b11);
      $fclose(fh);
    end

    @(negedge clk);
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    step;                                 // Reset edge
    @(negedge clk);
    reset = 1'b0; enable = 1'b1; addend = x1;
    step;                                 // Add x1
    total1 = total;
    @(negedge clk);
    addend = x2;
    step;                                 // Add x2
    total2 = total; zero2 = zero; carry2 = carry;
    @(negedge clk);
    enable = 1'b0;

    `CHECK("CH08_TOTAL1", `P_CH08_TOTAL1, total1)
    `CHECK("CH08_TOTAL2", `P_CH08_TOTAL2, total2)
    `CHECK("CH08_ZERO2",  `P_CH08_ZERO2,  zero2)
    `CHECK("CH08_CARRY2", `P_CH08_CARRY2, carry2)
    `FINISH_CHECK("ch08", sid)
  end
endmodule
