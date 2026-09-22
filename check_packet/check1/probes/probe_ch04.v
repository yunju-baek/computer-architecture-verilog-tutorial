// 점검 1-4. CH04 조합논리. 기본값 선행 배정 디코더와 4:1 mux의 출력을 예상한다.
// 대상: tutorial/ch04/ex02_default.v (with_default), tutorial/ch04/ex01_mux4.v
`timescale 1ns/1ps

module probe_ch04;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3, s4, s5, s6;
  reg  [3:0]  opcode;
  wire [1:0]  alu_select;
  wire        write_enable, memory_read, illegal;
  reg  [7:0]  in0, in1, in2, in3;
  reg  [1:0]  sel;
  wire [7:0]  y;
  integer     fails;

  with_default decoder(.opcode(opcode), .alu_select(alu_select),
                       .write_enable(write_enable), .memory_read(memory_read),
                       .illegal(illegal));
  ex01_mux4 mux(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel), .y(y));

  initial begin
    fails = 0;
    read_student_id(sid);

    // 입력 파생: salt 0x5A5A0400
    s1 = lcg_next(sid ^ 32'h5A5A0400);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    s4 = lcg_next(s3);
    s5 = lcg_next(s4);
    s6 = lcg_next(s5);
    opcode = s1[31:28];
    in0    = s2[31:24];
    in1    = s3[31:24];
    in2    = s4[31:24];
    in3    = s5[31:24];
    sel    = s6[31:30];

    $display("=== probe_ch04 STUDENT_ID=%0d ===", sid);
    $display("INPUT with_default: opcode=%h", opcode);
    $display("INPUT ex01_mux4:    in0=%h in1=%h in2=%h in3=%h sel=%b", in0, in1, in2, in3, sel);
    #1;

    `CHECK("CH04_ALU_SELECT",   `P_CH04_ALU_SELECT,   alu_select)
    `CHECK("CH04_WRITE_ENABLE", `P_CH04_WRITE_ENABLE, write_enable)
    `CHECK("CH04_MEMORY_READ",  `P_CH04_MEMORY_READ,  memory_read)
    `CHECK("CH04_ILLEGAL",      `P_CH04_ILLEGAL,      illegal)
    `CHECK("CH04_MUX_Y",        `P_CH04_MUX_Y,        y)
    `FINISH_CHECK("ch04", sid)
  end
endmodule
