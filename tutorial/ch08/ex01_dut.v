// 예제 8-1부터 8-5까지 검사 대상으로 쓰는 모듈.
// 누적기 하나와 플래그를 갖춘다.
`timescale 1ns/1ps

module ex01_dut(
  input  wire        clk,
  input  wire        reset,
  input  wire        enable,
  input  wire [15:0] addend,
  output reg  [15:0] total,
  output wire        zero,
  output wire        carry
);

  reg carry_state;

  always @(posedge clk) begin
    if (reset) begin
      total       <= 16'h0000;
      carry_state <= 1'b0;
    end
    else if (enable) begin
      total       <= total + addend;
      carry_state <= ({1'b0, total} + {1'b0, addend}) >> 16;
    end
  end

  assign zero  = ~|total;
  assign carry = carry_state;

endmodule
