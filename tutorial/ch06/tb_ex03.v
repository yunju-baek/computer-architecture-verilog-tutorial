// 예제 6-3의 testbench. 같은 코드를 세 폭으로 만든다.
`timescale 1ns/1ps

module tb_ex03;

  reg  [3:0]  a4, b4;
  wire [3:0]  sum4;
  wire        carry4;

  reg  [7:0]  a8, b8;
  wire [7:0]  sum8;
  wire        carry8;

  reg  [31:0] a32, b32;
  wire [31:0] sum32;
  wire        carry32;

  integer i, j;

  ex03_generate #(.WIDTH(4))  u4 (.a(a4),  .b(b4),  .carry_in(1'b0),
                                  .sum(sum4),  .carry_out(carry4));
  ex03_generate #(.WIDTH(8))  u8 (.a(a8),  .b(b8),  .carry_in(1'b0),
                                  .sum(sum8),  .carry_out(carry8));
  ex03_generate #(.WIDTH(32)) u32(.a(a32), .b(b32), .carry_in(1'b0),
                                  .sum(sum32), .carry_out(carry32));

  initial begin
    $display("--- generate 이름으로 개별 instance에 접근한다 ---");
    a4 = 4'hf; b4 = 4'h1; #1;
    $display("u4.adder_stage[0].u_fa.sum = %b", u4.adder_stage[0].u_fa.sum);
    $display("u4.adder_stage[3].u_fa.carry_out = %b", u4.adder_stage[3].u_fa.carry_out);

    $display("--- WIDTH 4 전수 검사 ---");
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        a4 = i[3:0]; b4 = j[3:0]; #1;
        if ({carry4, sum4} !== ({1'b0, a4} + {1'b0, b4}))
          $fatal(1, "FAIL WIDTH=4 a=%h b=%h", a4, b4);
      end
    end

    $display("--- WIDTH 8 표본 검사 ---");
    a8 = 8'hff; b8 = 8'h01; #1;
    if ({carry8, sum8} !== 9'h100) $fatal(1, "FAIL WIDTH=8 sum=%h carry=%b", sum8, carry8);
    $display("ff + 01 = sum %h carry %b", sum8, carry8);

    $display("--- WIDTH 32 표본 검사 ---");
    a32 = 32'hffff_ffff; b32 = 32'h1; #1;
    if (sum32 !== 32'h0 || carry32 !== 1'b1)
      $fatal(1, "FAIL WIDTH=32 sum=%h carry=%b", sum32, carry32);
    $display("ffffffff + 00000001 = sum %h carry %b", sum32, carry32);

    a32 = 32'h1234_5678; b32 = 32'h8765_4321; #1;
    if ({carry32, sum32} !== ({1'b0, 32'h1234_5678} + {1'b0, 32'h8765_4321}))
      $fatal(1, "FAIL WIDTH=32 sum=%h", sum32);
    $display("12345678 + 87654321 = sum %h carry %b", sum32, carry32);

    $display("PASS ch06 ex03 generate");
    $finish(0);
  end

endmodule
