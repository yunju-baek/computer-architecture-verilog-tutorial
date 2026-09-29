// 예제 2-3. 같은 회로를 assign과 always @*로 각각 쓴다.
// 좌변 신호의 자료형이 대입 방식에 따라 달라진다.
`timescale 1ns/1ps

// 방식 1. wire 출력을 assign으로 구동한다.
module mux_with_assign(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output wire [3:0] y
);
  assign y = sel ? b : a;
endmodule

// 방식 2. reg 출력을 always @* 안에서 구동한다.
module mux_with_always(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output reg  [3:0] y
);
  always @* begin
    y = a;            // 기본값을 먼저 준다
    if (sel)
      y = b;          // 조건이 맞으면 덮어쓴다
  end
endmodule
