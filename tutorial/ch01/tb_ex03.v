// 예제 1-3의 testbench. 진리표를 출력하고 동시에 값을 검사한다.
`timescale 1ns/1ps

module tb_ex03;

  reg  a, b;
  wire y_and, y_or, y_xor, y_nand;
  integer i;

  ex03_gates dut(
    .a(a), .b(b),
    .y_and(y_and), .y_or(y_or), .y_xor(y_xor), .y_nand(y_nand)
  );

  initial begin
    $display(" a b | and or xor nand");
    $display("-----+-------------------");
    for (i = 0; i < 4; i = i + 1) begin
      a = i[1];
      b = i[0];
      #1;
      $display(" %b %b |  %b   %b   %b    %b", a, b, y_and, y_or, y_xor, y_nand);
      if (y_and  !== (a & b))    $fatal(1, "FAIL y_and  a=%b b=%b", a, b);
      if (y_or   !== (a | b))    $fatal(1, "FAIL y_or   a=%b b=%b", a, b);
      if (y_xor  !== (a ^ b))    $fatal(1, "FAIL y_xor  a=%b b=%b", a, b);
      if (y_nand !== ~(a & b))   $fatal(1, "FAIL y_nand a=%b b=%b", a, b);
    end
    $display("PASS ch01 ex03 gates, 4 vectors");
    $finish(0);
  end

endmodule
