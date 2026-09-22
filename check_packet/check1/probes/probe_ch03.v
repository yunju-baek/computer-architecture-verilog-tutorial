// 점검 1-3. CH03 비트 폭 규칙. 4비트 두 값의 덧셈을 4비트와 5비트에 담은 결과를 예상한다.
// 대상: tutorial/ch03/ex02_width_rules.v 의 규칙 1, 2와 ex03_signed.v 의 부호 해석
`timescale 1ns/1ps

module probe_ch03;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2;
  reg  [3:0]  a, b;
  reg  [3:0]  narrow_sum;
  reg  [4:0]  wide_sum;
  reg         carry_bit;
  integer     a_signed;
  integer     fails;

  initial begin
    fails = 0;
    read_student_id(sid);

    // 입력 파생: salt 0x5A5A0300
    s1 = lcg_next(sid ^ 32'h5A5A0300);
    s2 = lcg_next(s1);
    a = s1[31:28];
    b = s2[31:28];

    $display("=== probe_ch03 STUDENT_ID=%0d ===", sid);
    $display("INPUT a=%b (%0d)  b=%b (%0d)  두 값은 부호 없는 4비트로 해석한다", a, a, b, b);

    // 규칙 1. 좌변 폭이 연산 폭을 정한다.
    narrow_sum = a + b;
    // 규칙 2. 자리올림은 폭을 넓혀 얻는다.
    wide_sum   = {1'b0, a} + {1'b0, b};
    carry_bit  = wide_sum[4];
    // 부호 해석. 같은 비트열 a를 4비트 signed로 읽은 값.
    a_signed   = $signed(a);
    #1;

    `CHECK ("CH03_NARROW_SUM", `P_CH03_NARROW_SUM, narrow_sum)
    `CHECK ("CH03_WIDE_SUM",   `P_CH03_WIDE_SUM,   wide_sum)
    `CHECK ("CH03_CARRY",      `P_CH03_CARRY,      carry_bit)
    `CHECKD("CH03_A_SIGNED",   `P_CH03_A_SIGNED,   a_signed)
    `FINISH_CHECK("ch03", sid)
  end
endmodule
