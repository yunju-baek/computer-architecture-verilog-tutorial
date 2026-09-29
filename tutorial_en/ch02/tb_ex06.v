// 예제 2-6의 testbench. 같은 모듈을 4비트와 32비트로 각각 만든다.
`timescale 1ns/1ps

module tb_ex06;

  reg  [3:0]  a4, b4;
  wire [3:0]  sum4;
  wire        carry4;

  reg  [31:0] a32, b32;
  wire [31:0] sum32;
  wire        carry32;

  // 파라미터를 이름으로 넘긴다.
  ex06_adder #(.WIDTH(4))  u_add4 (.a(a4),  .b(b4),  .sum(sum4),  .carry(carry4));
  ex06_adder #(.WIDTH(32)) u_add32(.a(a32), .b(b32), .sum(sum32), .carry(carry32));

  initial begin
    a4 = 4'hf; b4 = 4'h1; #1;
    $display("WIDTH=4  : %h + %h = sum %h carry %b", a4, b4, sum4, carry4);
    if (sum4 !== 4'h0 || carry4 !== 1'b1) $fatal(1, "FAIL 4bit");

    a4 = 4'h3; b4 = 4'h4; #1;
    $display("WIDTH=4  : %h + %h = sum %h carry %b", a4, b4, sum4, carry4);
    if (sum4 !== 4'h7 || carry4 !== 1'b0) $fatal(1, "FAIL 4bit");

    a32 = 32'hffff_ffff; b32 = 32'h1; #1;
    $display("WIDTH=32 : %h + %h = sum %h carry %b", a32, b32, sum32, carry32);
    if (sum32 !== 32'h0 || carry32 !== 1'b1) $fatal(1, "FAIL 32bit");

    a32 = 32'h1000_0000; b32 = 32'h2000_0000; #1;
    $display("WIDTH=32 : %h + %h = sum %h carry %b", a32, b32, sum32, carry32);
    if (sum32 !== 32'h3000_0000 || carry32 !== 1'b0) $fatal(1, "FAIL 32bit");

    $display("PASS ch02 ex06 parameter");
    $finish(0);
  end

endmodule
