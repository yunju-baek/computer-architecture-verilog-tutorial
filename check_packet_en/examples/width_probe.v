// Based on tutorial/ch03/ex02_width_rules.v: explicit addition widths.
`timescale 1ns/1ps
module width_probe;
  reg  [3:0] a, b;
  wire [3:0] narrow_sum;
  wire [4:0] wide_sum;

  assign narrow_sum = a + b;
  assign wide_sum = {1'b0, a} + {1'b0, b};

  initial begin
    // Edit these two inputs for each experiment.
    a = 4'hf;
    b = 4'h1;
    #1;
    $display("a=%0d b=%0d", a, b);
    $display("narrow=%04b (%0d)", narrow_sum, narrow_sum);
    $display("wide=%05b (%0d)", wide_sum, wide_sum);
    $finish;
  end
endmodule
