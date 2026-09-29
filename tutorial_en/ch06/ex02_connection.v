// 예제 6-2. 포트를 연결하는 두 방식
`timescale 1ns/1ps

module divider_stub(
  input  wire [7:0] numerator,
  input  wire [7:0] denominator,
  output wire [7:0] quotient,
  output wire [7:0] remainder
);
  assign quotient  = (denominator == 8'd0) ? 8'hff : numerator / denominator;
  assign remainder = (denominator == 8'd0) ? 8'hff : numerator % denominator;
endmodule

module ex02_connection(
  input  wire [7:0] value_a,
  input  wire [7:0] value_b,
  output wire [7:0] named_quotient,
  output wire [7:0] named_remainder,
  output wire [7:0] ordered_quotient,
  output wire [7:0] ordered_remainder
);

  // 이름 기반 연결. 포트 이름을 명시하므로 순서가 자유롭다.
  divider_stub u_named(
    .remainder(named_remainder),
    .quotient(named_quotient),
    .denominator(value_b),
    .numerator(value_a)
  );

  // 순서 기반 연결. 선언 순서에 맞춰 적어야 한다.
  divider_stub u_ordered(
    value_a, value_b, ordered_quotient, ordered_remainder
  );

endmodule
