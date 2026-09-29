// 예제 2-4. 벡터에서 비트를 꺼내는 3가지 방법
`timescale 1ns/1ps

module ex04_select(
  input  wire [31:0] instr,      // RV32I 명령어 한 워드를 가정한다
  output wire [6:0]  opcode,     // instr[6:0]
  output wire [4:0]  rd,         // instr[11:7]
  output wire [2:0]  funct3,     // instr[14:12]
  output wire [4:0]  rs1,        // instr[19:15]
  output wire [4:0]  rs2,        // instr[24:20]
  output wire [6:0]  funct7,     // instr[31:25]
  output wire        sign_bit    // instr[31]
);

  // 고정 part select. 시작과 끝을 상수로 적는다.
  assign opcode   = instr[6:0];
  assign rd       = instr[11:7];
  assign funct3   = instr[14:12];
  assign rs1      = instr[19:15];
  assign rs2      = instr[24:20];
  assign funct7   = instr[31:25];

  // bit select. 한 비트만 꺼낸다.
  assign sign_bit = instr[31];

endmodule
