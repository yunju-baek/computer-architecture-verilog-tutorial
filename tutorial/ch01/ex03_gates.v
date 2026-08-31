// 예제 1-3. 하나의 module이 여러 출력을 가질 수 있다.
`timescale 1ns/1ps

module ex03_gates(
  input  wire a,
  input  wire b,
  output wire y_and,
  output wire y_or,
  output wire y_xor,
  output wire y_nand
);

  assign y_and  = a & b;
  assign y_or   = a | b;
  assign y_xor  = a ^ b;
  assign y_nand = ~(a & b);

endmodule
