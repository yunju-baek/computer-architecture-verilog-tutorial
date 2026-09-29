// 예제 5-1. D 플립플롭. 순차 논리의 최소 단위다.
`timescale 1ns/1ps

module ex01_dff(
  input  wire       clk,
  input  wire       reset,     // 동기 리셋
  input  wire [7:0] d,
  output reg  [7:0] q
);

  // clock 상승 에지에서만 상태를 갱신한다.
  always @(posedge clk) begin
    if (reset)
      q <= 8'h00;
    else
      q <= d;
  end

endmodule
