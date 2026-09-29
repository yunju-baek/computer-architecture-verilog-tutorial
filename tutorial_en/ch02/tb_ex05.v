// 예제 2-5의 testbench.
`timescale 1ns/1ps

module tb_ex05;

  reg  [31:0] instr;
  wire [31:0] imm_i, imm_s, imm_u, zero_ext_i;

  // carry를 얻는 관용 표현 확인용
  reg  [3:0]  op_a, op_b;
  wire [4:0]  sum_with_carry;

  ex05_concat dut(
    .instr(instr), .imm_i(imm_i), .imm_s(imm_s),
    .imm_u(imm_u), .zero_ext_i(zero_ext_i)
  );

  // 4비트 두 값을 더해 5비트로 받으면 최상위 비트가 carry가 된다.
  assign sum_with_carry = op_a + op_b;

  initial begin
    $display("--- 양수 즉치수 ---");
    // addi x1, x0, 5  =  0x00500093, instr[31:20] = 0x005
    instr = 32'h00500093;
    #1;
    $display("instr[31:20] = %h", instr[31:20]);
    $display("imm_i        = %h (%0d)", imm_i, $signed(imm_i));
    if (imm_i !== 32'h0000_0005) $fatal(1, "FAIL imm_i=%h", imm_i);

    $display("--- 음수 즉치수. 부호 확장과 0 확장이 갈라진다 ---");
    // addi x1, x0, -1  =  0xfff00093, instr[31:20] = 0xfff
    instr = 32'hfff00093;
    #1;
    $display("instr[31:20] = %h", instr[31:20]);
    $display("imm_i        = %h (%0d)  20비트를 부호로 채운다", imm_i, $signed(imm_i));
    $display("zero_ext_i   = %h (%0d)  20비트를 0으로 채운다", zero_ext_i, zero_ext_i);
    if (imm_i      !== 32'hffff_ffff) $fatal(1, "FAIL imm_i=%h", imm_i);
    if (zero_ext_i !== 32'h0000_0fff) $fatal(1, "FAIL zero_ext_i=%h", zero_ext_i);

    $display("--- S-type. 나뉜 두 필드를 이어 붙인다 ---");
    // sw x2, 8(x1)  =  0x0020a423
    instr = 32'h0020a423;
    #1;
    $display("instr[31:25] = %b  instr[11:7] = %b", instr[31:25], instr[11:7]);
    $display("imm_s        = %h (%0d)", imm_s, $signed(imm_s));
    if (imm_s !== 32'h0000_0008) $fatal(1, "FAIL imm_s=%h", imm_s);

    $display("--- U-type. 하위 12비트를 0으로 채운다 ---");
    // lui x1, 0x12345  =  0x123450b7
    instr = 32'h123450b7;
    #1;
    $display("imm_u        = %h", imm_u);
    if (imm_u !== 32'h1234_5000) $fatal(1, "FAIL imm_u=%h", imm_u);

    $display("--- concatenation으로 carry를 얻는다 ---");
    op_a = 4'hf; op_b = 4'h1; #1;
    $display("4'hf + 4'h1 -> 5비트 결과 %b, carry=%b sum=%h",
             sum_with_carry, sum_with_carry[4], sum_with_carry[3:0]);
    if (sum_with_carry !== 5'b1_0000) $fatal(1, "FAIL sum_with_carry=%b", sum_with_carry);

    op_a = 4'h3; op_b = 4'h4; #1;
    $display("4'h3 + 4'h4 -> 5비트 결과 %b, carry=%b sum=%h",
             sum_with_carry, sum_with_carry[4], sum_with_carry[3:0]);
    if (sum_with_carry !== 5'b0_0111) $fatal(1, "FAIL sum_with_carry=%b", sum_with_carry);

    $display("PASS ch02 ex05 concat");
    $finish(0);
  end

endmodule
