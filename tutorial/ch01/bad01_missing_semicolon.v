// 의도적 오류 1. assign 문 끝의 세미콜론이 빠져 있다.
// 컴파일이 실패하는 것을 확인하고 오류 메시지 읽는 법을 익히는 예제다.
`timescale 1ns/1ps

module bad01_missing_semicolon(
  input  wire [3:0] a,
  output wire [3:0] y
);

  assign y = ~a

endmodule
