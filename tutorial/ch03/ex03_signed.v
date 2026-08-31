// 예제 3-3. 같은 비트 패턴을 부호 있게 또 부호 없게 해석한다.
`timescale 1ns/1ps

module ex03_signed;

  reg [3:0]        u;    // 부호 없는 선언
  reg signed [3:0] s;    // 부호 있는 선언

  reg [3:0]        neg_value, divisor;

  initial begin
    $display("--- 선언이 해석을 정한다 ---");
    u = 4'b1111;
    s = 4'b1111;
    $display("4'b1111을 부호 없이 읽으면 %0d", u);
    $display("4'b1111을 부호 있게 읽으면 %0d", s);

    $display("--- $signed와 $unsigned로 해석을 바꾼다 ---");
    u = 4'b1010;
    $display("u          = %b -> %0d", u, u);
    $display("$signed(u) = %b -> %0d", u, $signed(u));
    s = -4'sd6;
    $display("s            = %b -> %0d", s, s);
    $display("$unsigned(s) = %b -> %0d", s, $unsigned(s));

    $display("--- 비교 결과가 해석에 따라 갈라진다 ---");
    u = 4'b1111;
    s = 4'b1111;
    $display("u > 4'd0 -> %b  15 > 0 이므로 참이다", u > 4'd0);
    $display("s > 4'sd0 -> %b  -1 > 0 이므로 거짓이다", s > 4'sd0);

    $display("--- 혼합 규칙. 부호 없는 값이 하나라도 있으면 전체가 부호 없이 계산된다 ---");
    s = -4'sd1;
    u = 4'd1;
    $display("s        = %b (%0d)", s, s);
    $display("s < 4'sd1 -> %b  부호 있는 비교", s < 4'sd1);
    $display("s < u     -> %b  u가 부호 없으므로 s도 부호 없이 읽힌다", s < u);
    $display("$signed(s) < $signed(u) -> %b  양쪽에 붙이면 부호 비교가 된다",
             $signed(s) < $signed(u));

    $display("--- 부호 확장과 0 확장 ---");
    s = -4'sd2;
    $display("s를 8비트로 부호 확장 = %b", {{4{s[3]}}, s});
    $display("s를 8비트로 0 확장    = %b", {4'b0, s});

    $display("--- 나눗셈과 우측 시프트의 차이 ---");
    neg_value   = 4'b1000;   // 부호 없이 8, 부호 있게 -8
    divisor = 4'b0010;   // 2
    $display("neg_value = %b", neg_value);
    $display("neg_value >> 1              = %b  부호 없는 시프트", neg_value >> 1);
    $display("$signed(neg_value) >>> 1    = %b  부호 있는 시프트", $signed(neg_value) >>> 1);
    $display("$signed(neg_value) / $signed(divisor) = %0d", $signed(neg_value) / $signed(divisor));

    $finish(0);
  end

endmodule
