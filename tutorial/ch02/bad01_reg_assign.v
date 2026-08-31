// 의도적 오류 1. reg로 선언한 신호를 assign으로 구동한다.
// -g2001로 컴파일하면 오류가 나고, -g2012로 컴파일하면 통과한다.
// 두 표준의 차이를 직접 확인하는 예제다.
`timescale 1ns/1ps

module bad01_reg_assign(
  input  wire [3:0] a,
  output reg  [3:0] y      // reg로 선언했다
);

  assign y = ~a;           // assign으로 구동한다

endmodule
