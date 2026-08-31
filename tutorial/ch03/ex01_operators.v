// 예제 3-1. 연산자를 분류별로 확인한다.
`timescale 1ns/1ps

module ex01_operators;

  reg [3:0] a, b;
  reg [3:0] zero_value;

  initial begin
    a = 4'b1100;   // 12
    b = 4'b0101;   // 5
    zero_value = 4'b0000;

    $display("a = %b (%0d), b = %b (%0d)", a, a, b, b);

    $display("--- 산술 연산자. 결과는 값이다 ---");
    $display("a + b  = %b", a + b);
    $display("a - b  = %b", a - b);
    $display("a * b  = %b", a * b);
    $display("a / b  = %b  정수 나눗셈이다", a / b);
    $display("a %% b  = %b  나머지다", a % b);

    $display("--- 비트 연산자. 비트마다 독립으로 계산한다 ---");
    $display("~a     = %b", ~a);
    $display("a & b  = %b", a & b);
    $display("a | b  = %b", a | b);
    $display("a ^ b  = %b", a ^ b);

    $display("--- 논리 연산자. 결과는 1비트다 ---");
    $display("!a         = %b  a가 0인지 판단한다", !a);
    $display("!zero_value= %b", !zero_value);
    $display("a && b     = %b  둘 다 0이 아니면 1이다", a && b);
    $display("a || b     = %b", a || b);
    $display("zero_value && b = %b", zero_value && b);

    $display("--- 비트 연산자와 논리 연산자를 혼동하면 결과가 달라진다 ---");
    $display("a & b  = %b  비트마다 AND", a & b);
    $display("a && b = %b  값이 0인지로 판단", a && b);

    $display("--- reduction 연산자. 벡터 하나를 1비트로 줄인다 ---");
    $display("&a     = %b  모든 비트가 1인지", &a);
    $display("|a     = %b  하나라도 1인지", |a);
    $display("^a     = %b  1인 비트가 홀수 개인지", ^a);
    $display("~|a    = %b  모든 비트가 0인지", ~|a);
    $display("~|zero_value = %b", ~|zero_value);

    $display("--- 관계 연산자. 결과는 1비트다 ---");
    $display("a > b  = %b", a > b);
    $display("a < b  = %b", a < b);
    $display("a >= b = %b", a >= b);

    $display("--- 등가 연산자 ---");
    $display("a == b = %b", a == b);
    $display("a != b = %b", a != b);

    $display("--- 조건 연산자. 2:1 선택을 한 줄로 쓴다 ---");
    $display("(a > b) ? a : b = %b", (a > b) ? a : b);

    $finish(0);
  end

endmodule
