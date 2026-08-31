// 예제 4-1. 4:1 multiplexer. case로 병렬 선택을 표현한다.
`timescale 1ns/1ps

module ex01_mux4(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire [7:0] in2,
  input  wire [7:0] in3,
  input  wire [1:0] sel,
  output reg  [7:0] y
);

  // always @* 는 오른쪽에 등장하는 모든 신호를 자동으로 감지한다.
  always @* begin
    case (sel)
      2'b00:   y = in0;
      2'b01:   y = in1;
      2'b10:   y = in2;
      default: y = in3;    // default가 남은 모든 경우를 덮는다
    endcase
  end

endmodule
