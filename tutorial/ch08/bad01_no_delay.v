// 의도적 함정 1. clock 에지 직후에 대기 없이 값을 읽는다.
`timescale 1ns/1ps

module bad01_no_delay;
  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;
  integer     step;

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    @(posedge clk); #1;
    reset = 1'b0;

    $display("step | 대기 없이 읽은 값  1ns 뒤 읽은 값");
    $display("-----+--------------------------------");

    for (step = 1; step <= 3; step = step + 1) begin
      enable = 1'b1;
      addend = 16'h0100;
      @(posedge clk);
      // 대기 없이 읽는다.
      $write("  %0d  |       %h        ", step, total);
      #1;
      // 1ns 뒤 읽는다.
      $display("       %h", total);
      enable = 1'b0;
      @(posedge clk); #1;
    end

    $display("에지와 같은 시각에는 갱신 전 값이 보인다");
    $finish(0);
  end
endmodule
