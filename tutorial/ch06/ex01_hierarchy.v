// 예제 6-1. 계층 구조. 작은 모듈을 쌓아 큰 모듈을 만든다.
`timescale 1ns/1ps

// 1층. 가장 작은 단위. 1비트 전가산기
module full_adder(
  input  wire a,
  input  wire b,
  input  wire carry_in,
  output wire sum,
  output wire carry_out
);
  assign sum       = a ^ b ^ carry_in;
  assign carry_out = (a & b) | (carry_in & (a ^ b));
endmodule

// 2층. 전가산기 4개를 이어 4비트 가산기를 만든다.
module adder4(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       carry_in,
  output wire [3:0] sum,
  output wire       carry_out
);
  // 자리올림을 전달하는 중간 신호. 폭과 함께 선언한다.
  wire [4:0] carry_chain;

  assign carry_chain[0] = carry_in;
  assign carry_out      = carry_chain[4];

  full_adder u_bit0(.a(a[0]), .b(b[0]), .carry_in(carry_chain[0]),
                    .sum(sum[0]), .carry_out(carry_chain[1]));
  full_adder u_bit1(.a(a[1]), .b(b[1]), .carry_in(carry_chain[1]),
                    .sum(sum[1]), .carry_out(carry_chain[2]));
  full_adder u_bit2(.a(a[2]), .b(b[2]), .carry_in(carry_chain[2]),
                    .sum(sum[2]), .carry_out(carry_chain[3]));
  full_adder u_bit3(.a(a[3]), .b(b[3]), .carry_in(carry_chain[3]),
                    .sum(sum[3]), .carry_out(carry_chain[4]));
endmodule

// 3층. 4비트 가산기 2개로 8비트 가산기를 만든다.
module ex01_hierarchy(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] sum,
  output wire       carry_out
);
  wire middle_carry;

  adder4 u_low (.a(a[3:0]), .b(b[3:0]), .carry_in(1'b0),
                .sum(sum[3:0]), .carry_out(middle_carry));
  adder4 u_high(.a(a[7:4]), .b(b[7:4]), .carry_in(middle_carry),
                .sum(sum[7:4]), .carry_out(carry_out));
endmodule
