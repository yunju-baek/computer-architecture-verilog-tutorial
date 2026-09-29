// 예제 1-2. 첫 회로 module. 4비트 입력을 비트마다 반전한다.
`timescale 1ns/1ps

module ex02_inverter(
  input  wire [3:0] a,   // 입력 포트. 폭은 4비트
  output wire [3:0] y    // 출력 포트. 폭은 4비트
);

  // assign은 우변 값이 바뀔 때마다 좌변을 갱신한다.
  assign y = ~a;

endmodule
