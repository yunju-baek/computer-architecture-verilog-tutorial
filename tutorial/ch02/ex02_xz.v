// 예제 2-2. Verilog의 값은 4가지다. 0, 1, x, z
// x는 값이 미정인 상태, z는 고임피던스 상태를 뜻한다.
`timescale 1ns/1ps

module ex02_xz;

  reg  [3:0] uninitialized;   // 선언만 하고 대입을 생략한 reg
  reg  [3:0] partial;
  wire [3:0] floating;        // 구동원이 열린 wire
  reg  [3:0] compare_a, compare_b;

  initial begin
    $display("--- 선언만 한 reg는 x로 시작한다 ---");
    $display("uninitialized = %b", uninitialized);

    $display("--- 구동원이 열린 wire는 z가 된다 ---");
    $display("floating      = %b", floating);

    $display("--- x가 섞인 연산은 결과에도 x가 번진다 ---");
    partial = 4'b10xz;
    $display("4'b10xz       = %b", partial);
    $display("4'b10xz + 1   = %b", partial + 4'b1);
    $display("4'b10xz & 0   = %b", partial & 4'b0000);

    $display("--- == 와 === 의 차이 ---");
    compare_a = 4'b1x01;
    compare_b = 4'b1x01;
    $display("a=%b b=%b", compare_a, compare_b);
    $display("a == b  -> %b  x가 있으면 결과가 x가 된다", compare_a == compare_b);
    $display("a === b -> %b  x 자리까지 같으면 1이 된다", compare_a === compare_b);
    $display("a != b  -> %b", compare_a != compare_b);
    $display("a !== b -> %b", compare_a !== compare_b);

    $finish(0);
  end

endmodule
