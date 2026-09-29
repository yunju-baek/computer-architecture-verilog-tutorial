// 예제 3-4. 3가지 시프트 연산. RV32I의 sll, srl, sra에 대응한다.
`timescale 1ns/1ps

module ex04_shift(
  input  wire [31:0] value,
  input  wire [4:0]  amount,     // RV32I는 하위 5비트만 shift amount로 쓴다
  output wire [31:0] sll_result,  // 좌측 논리 시프트
  output wire [31:0] srl_result,  // 우측 논리 시프트. 상위를 0으로 채운다
  output wire [31:0] sra_result   // 우측 산술 시프트. 상위를 부호 비트로 채운다
);

  assign sll_result = value << amount;
  assign srl_result = value >> amount;

  // >>> 가 부호 비트를 채우려면 좌변 피연산자가 부호 있는 값이어야 한다.
  assign sra_result = $signed(value) >>> amount;

endmodule
