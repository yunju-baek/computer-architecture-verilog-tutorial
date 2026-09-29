// 의도적 함정 1. 연산자 우선순위.
// 등가 연산자가 비트 연산자보다 먼저 계산된다.
`timescale 1ns/1ps

module bad01_precedence;

  reg [3:0] a, b, c;

  initial begin
    a = 4'b1100;
    b = 4'b1010;
    c = 4'b1000;

    $display("a = %b, b = %b, c = %b", a, b, c);

    $display("--- 괄호를 생략하면 == 가 먼저 계산된다 ---");
    $display("a & b == c   = %b", a & b == c);
    $display("a & (b == c) = %b  위와 같은 계산이다", a & (b == c));
    $display("(a & b) == c = %b  의도한 계산은 이쪽이다", (a & b) == c);

    $display("--- 논리 부정과 비트 부정 ---");
    $display("!a  = %b  값이 0인지 판단한다", !a);
    $display("~a  = %b  비트마다 반전한다", ~a);

    $display("--- 조건 연산자는 우선순위가 가장 낮다 ---");
    $display("a > b ? a : b + 1     = %b", a > b ? a : b + 1);
    $display("(a > b) ? a : (b + 1) = %b  위와 같은 계산이다", (a > b) ? a : (b + 1));

    $finish(0);
  end

endmodule
