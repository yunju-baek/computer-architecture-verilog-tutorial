// 의도적 함정 2. instance의 포트 하나를 연결에서 빠뜨린다.
`timescale 1ns/1ps

module accumulate(
  input  wire       clk,
  input  wire       reset,
  input  wire [7:0] increment,
  output reg  [7:0] total
);
  always @(posedge clk) begin
    if (reset)
      total <= 8'd0;
    else
      total <= total + increment;
  end
endmodule

module bad02_unconnected;
  reg        clk = 1'b0;
  reg        reset;
  reg  [7:0] increment;
  wire [7:0] total_full, total_missing;

  always #5 clk = ~clk;

  // 포트를 모두 연결했다.
  accumulate u_full(.clk(clk), .reset(reset), .increment(increment), .total(total_full));

  // increment 포트를 연결에서 빠뜨렸다. 그 입력은 z가 된다.
  accumulate u_missing(.clk(clk), .reset(reset), .total(total_missing));

  initial begin
    reset = 1'b1; increment = 8'd3;
    @(posedge clk); #1;
    reset = 1'b0;

    repeat (3) @(posedge clk);
    #1;
    $display("increment=3 을 세 사이클 누적했다");
    $display("모두 연결 -> total=%0d", total_full);
    $display("포트 누락 -> total=%h  z가 섞여 x로 번졌다", total_missing);
    $finish(0);
  end
endmodule
