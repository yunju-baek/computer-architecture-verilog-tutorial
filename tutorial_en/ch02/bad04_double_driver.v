// 의도적 오류 4. 같은 신호를 assign과 절차 블록에서 함께 구동한다.
// 어느 표준에서도 오류가 난다.
`timescale 1ns/1ps

module bad04_double_driver(
  input  wire [3:0] a,
  output reg  [3:0] y
);

  assign y = ~a;           // 구동원 1
  always @* y = a;         // 구동원 2

endmodule
