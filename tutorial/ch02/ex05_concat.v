// 예제 2-5. concatenation과 replication으로 비트를 조립한다.
// RV32I 즉치수 생성이 바로 이 두 연산으로 이루어진다.
`timescale 1ns/1ps

module ex05_concat(
  input  wire [31:0] instr,
  output wire [31:0] imm_i,      // I-type 즉치수. 부호 확장한다
  output wire [31:0] imm_s,      // S-type 즉치수. 필드가 둘로 나뉘어 있다
  output wire [31:0] imm_u,      // U-type 즉치수. 상위 20비트를 그대로 쓴다
  output wire [31:0] zero_ext_i  // 같은 필드를 0 확장한 결과
);

  // I-type: instr[31:20]의 12비트를 32비트로 부호 확장한다.
  // 최상위 비트 instr[31]을 20번 복제해 앞에 붙인다.
  assign imm_i = {{20{instr[31]}}, instr[31:20]};

  // 같은 필드를 0으로 확장하면 결과가 달라진다.
  assign zero_ext_i = {20'b0, instr[31:20]};

  // S-type: instr[31:25]와 instr[11:7]을 이어 12비트를 만든 뒤 부호 확장한다.
  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

  // U-type: instr[31:12]를 상위에 놓고 하위 12비트를 0으로 채운다.
  assign imm_u = {instr[31:12], 12'b0};

endmodule
