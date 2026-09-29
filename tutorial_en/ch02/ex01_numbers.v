// 예제 2-1. 숫자 리터럴 표기법
// 형식은 <폭>'<진법><값>이다. 폭과 진법은 생략할 수 있다.
`timescale 1ns/1ps

module ex01_numbers;

  reg [7:0]  a;
  reg [31:0] b;

  initial begin
    $display("--- 같은 값을 4가지 진법으로 적는다 ---");
    a = 8'b1010_0011; $display("8'b1010_0011 -> %b = %h = %0d", a, a, a);
    a = 8'o243;       $display("8'o243       -> %b = %h = %0d", a, a, a);
    a = 8'd163;       $display("8'd163       -> %b = %h = %0d", a, a, a);
    a = 8'ha3;        $display("8'ha3        -> %b = %h = %0d", a, a, a);

    $display("--- underscore는 자리를 끊어 읽는 표기다 ---");
    b = 32'hdead_beef; $display("32'hdead_beef -> %h", b);
    b = 32'b1111_0000_1111_0000_1111_0000_1111_0000; $display("32비트 2진 -> %h", b);

    $display("--- 폭과 진법을 생략하면 기본값이 적용된다 ---");
    b = 'h1f;  $display("'h1f  -> %h  폭 생략은 32비트로 처리된다", b);
    b = 17;    $display("17    -> %h  진법 생략은 10진수로 처리된다", b);

    $display("--- 폭보다 값이 작으면 상위 비트가 0으로 채워진다 ---");
    a = 8'h5;  $display("8'h5  -> %b", a);

    $display("--- 모든 비트를 같은 값으로 채운다 ---");
    a = {8{1'b1}}; $display("{8{1'b1}} -> %b = %h", a, a);
    a = 8'hff;     $display("8'hff     -> %b = %h", a, a);

    $finish(0);
  end

endmodule
