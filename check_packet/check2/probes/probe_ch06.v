// 점검 2-1. CH06 계층과 generate. 8비트 ripple-carry 가산기의 출력과 중간 자리올림을 예상한다.
// 대상: tutorial/ch06/ex03_generate.v (WIDTH=8)
`timescale 1ns/1ps

module probe_ch06;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3;
  reg  [7:0]  a, b;
  reg         carry_in;
  wire [7:0]  sum;
  wire        carry_out;
  reg         mid_carry;
  integer     fails;

  ex03_generate #(.WIDTH(8)) dut(.a(a), .b(b), .carry_in(carry_in),
                                 .sum(sum), .carry_out(carry_out));

  initial begin
    fails = 0;
    read_student_id(sid);

    // 입력 파생: salt 0x5A5A0600
    s1 = lcg_next(sid ^ 32'h5A5A0600);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    a        = s1[31:24];
    b        = s2[31:24];
    carry_in = s3[31];

    $display("=== probe_ch06 STUDENT_ID=%0d ===", sid);
    $display("INPUT a=%h (%0d)  b=%h (%0d)  carry_in=%b", a, a, b, b, carry_in);
    $display("      MID_CARRY 는 adder_stage[3].u_fa.carry_out, 즉 하위 4비트에서 상위 4비트로 넘어가는 자리올림이다");
    #1;

    // 계층 이름으로 generate 안의 instance 신호를 읽는다.
    mid_carry = dut.adder_stage[3].u_fa.carry_out;

    `CHECK("CH06_SUM",       `P_CH06_SUM,       sum)
    `CHECK("CH06_CARRY_OUT", `P_CH06_CARRY_OUT, carry_out)
    `CHECK("CH06_MID_CARRY", `P_CH06_MID_CARRY, mid_carry)
    `FINISH_CHECK("ch06", sid)
  end
endmodule
