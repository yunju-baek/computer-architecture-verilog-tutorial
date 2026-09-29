// 예제 6-3. generate로 instance를 반복 생성한다.
// 예제 6-1에서 손으로 적은 instance 4개를 반복문 하나로 대체한다.
`timescale 1ns/1ps

module ex03_generate #(
  parameter WIDTH = 8
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  input  wire             carry_in,
  output wire [WIDTH-1:0] sum,
  output wire             carry_out
);

  wire [WIDTH:0] carry_chain;

  assign carry_chain[0] = carry_in;
  assign carry_out      = carry_chain[WIDTH];

  // genvar는 generate 반복문의 변수다. 합성 시각에만 존재한다.
  genvar bit_index;

  generate
    for (bit_index = 0; bit_index < WIDTH; bit_index = bit_index + 1) begin : adder_stage
      full_adder u_fa(
        .a(a[bit_index]),
        .b(b[bit_index]),
        .carry_in(carry_chain[bit_index]),
        .sum(sum[bit_index]),
        .carry_out(carry_chain[bit_index + 1])
      );
    end
  endgenerate

endmodule

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
