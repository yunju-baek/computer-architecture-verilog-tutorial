// 예제 4-4의 testbench.
`timescale 1ns/1ps

module tb_ex04;

  reg  [31:0] a, b;
  wire [31:0] max_unsigned, max_signed;
  wire [4:0]  leading_zeros;

  ex04_function dut(.a(a), .b(b),
                    .max_unsigned(max_unsigned), .max_signed(max_signed),
                    .leading_zeros(leading_zeros));

  initial begin
    $display("--- 같은 입력에 두 해석을 적용한다 ---");
    a = 32'hffff_ffff;   // 부호 없이 크고, 부호 있게 -1
    b = 32'h0000_0001;
    #1;
    $display("a = %h, b = %h", a, b);
    $display("max_unsigned = %h", max_unsigned);
    $display("max_signed   = %h", max_signed);
    if (max_unsigned !== 32'hffff_ffff) $fatal(1, "FAIL max_unsigned=%h", max_unsigned);
    if (max_signed   !== 32'h0000_0001) $fatal(1, "FAIL max_signed=%h", max_signed);

    $display("--- function 안의 반복문도 조합 논리가 된다 ---");
    a = 32'h8000_0000; #1;
    $display("a = %h -> leading_zeros = %0d", a, leading_zeros);
    if (leading_zeros !== 5'd0) $fatal(1, "FAIL leading_zeros=%0d", leading_zeros);

    a = 32'h0000_0001; #1;
    $display("a = %h -> leading_zeros = %0d", a, leading_zeros);
    if (leading_zeros !== 5'd31) $fatal(1, "FAIL leading_zeros=%0d", leading_zeros);

    a = 32'h0100_0000; #1;
    $display("a = %h -> leading_zeros = %0d", a, leading_zeros);
    if (leading_zeros !== 5'd7) $fatal(1, "FAIL leading_zeros=%0d", leading_zeros);

    $display("PASS ch04 ex04 function");
    $finish(0);
  end

endmodule
