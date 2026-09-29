// Check 1-2. CH02 Bit Selection. Predict 6 fields sliced from an RV32I instruction word.
// Target: tutorial/ch02/ex04_select.v
`timescale 1ns/1ps

module probe_ch02;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2;
  reg  [31:0] instr;
  wire [6:0]  opcode, funct7;
  wire [4:0]  rd, rs1, rs2;
  wire [2:0]  funct3;
  wire        sign_bit;
  integer     fails;

  ex04_select dut(.instr(instr), .opcode(opcode), .rd(rd), .funct3(funct3),
                  .rs1(rs1), .rs2(rs2), .funct7(funct7), .sign_bit(sign_bit));

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0200. Concatenates high 16 bits across two steps to form 32-bit word.
    s1 = lcg_next(sid ^ 32'h5A5A0200);
    s2 = lcg_next(s1);
    instr = {s1[31:16], s2[31:16]};

    $display("=== probe_ch02 STUDENT_ID=%0d ===", sid);
    $display("INPUT instr=%h", instr);
    $display("INPUT instr=%b", instr);
    $display("      bit    31       24 23      16 15       8 7        0");
    #1;

    `CHECK("CH02_OPCODE", `P_CH02_OPCODE, opcode)
    `CHECK("CH02_RD",     `P_CH02_RD,     rd)
    `CHECK("CH02_FUNCT3", `P_CH02_FUNCT3, funct3)
    `CHECK("CH02_RS1",    `P_CH02_RS1,    rs1)
    `CHECK("CH02_RS2",    `P_CH02_RS2,    rs2)
    `CHECK("CH02_FUNCT7", `P_CH02_FUNCT7, funct7)
    `FINISH_CHECK("ch02", sid)
  end
endmodule
