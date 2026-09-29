// 예제 2-4의 testbench. 실제 RV32I 명령어를 넣어 필드 분해를 확인한다.
`timescale 1ns/1ps

module tb_ex04;

  reg  [31:0] instr;
  wire [6:0]  opcode, funct7;
  wire [4:0]  rd, rs1, rs2;
  wire [2:0]  funct3;
  wire        sign_bit;

  // indexed part select 확인용. 시작 위치를 변수로 줄 수 있다.
  reg  [31:0] data;
  reg  [1:0]  byte_index;
  wire [7:0]  selected_byte;

  ex04_select dut(
    .instr(instr), .opcode(opcode), .rd(rd), .funct3(funct3),
    .rs1(rs1), .rs2(rs2), .funct7(funct7), .sign_bit(sign_bit)
  );

  // [base +: width]는 base에서 시작해 위로 width비트를 꺼낸다.
  assign selected_byte = data[byte_index*8 +: 8];

  initial begin
    // add x3, x1, x2  =  0x002081b3
    instr = 32'h002081b3;
    #1;
    $display("instr  = %h", instr);
    $display("opcode = %b (%h)", opcode, opcode);
    $display("rd     = %0d", rd);
    $display("funct3 = %b", funct3);
    $display("rs1    = %0d", rs1);
    $display("rs2    = %0d", rs2);
    $display("funct7 = %b", funct7);

    if (opcode !== 7'b0110011) $fatal(1, "FAIL opcode=%b", opcode);
    if (rd     !== 5'd3)       $fatal(1, "FAIL rd=%0d", rd);
    if (funct3 !== 3'b000)     $fatal(1, "FAIL funct3=%b", funct3);
    if (rs1    !== 5'd1)       $fatal(1, "FAIL rs1=%0d", rs1);
    if (rs2    !== 5'd2)       $fatal(1, "FAIL rs2=%0d", rs2);
    if (funct7 !== 7'b0000000) $fatal(1, "FAIL funct7=%b", funct7);

    // sign_bit 확인. 최상위 비트가 1인 값을 넣는다.
    instr = 32'hfff00093;
    #1;
    $display("instr  = %h  sign_bit = %b", instr, sign_bit);
    if (sign_bit !== 1'b1) $fatal(1, "FAIL sign_bit=%b", sign_bit);

    // indexed part select
    data = 32'hdd_cc_bb_aa;
    $display("--- data[index*8 +: 8] ---");
    for (byte_index = 0; byte_index < 3; byte_index = byte_index + 1) begin
      #1;
      $display("byte_index=%0d -> %h", byte_index, selected_byte);
    end
    byte_index = 3; #1;
    $display("byte_index=%0d -> %h", byte_index, selected_byte);
    if (selected_byte !== 8'hdd) $fatal(1, "FAIL selected_byte=%h", selected_byte);

    $display("PASS ch02 ex04 select");
    $finish(0);
  end

endmodule
