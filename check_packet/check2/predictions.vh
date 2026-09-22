// 점검 2 예상값 기록 파일. make test 가 이 값을 실제 실행 결과와 비교한다.
//
// 작성 방법
//   1. make show-inputs 로 자신의 학번에서 파생된 입력값을 본다.
//   2. 해당 장의 원본 소스를 읽고 출력을 손으로 계산한다.
//   3. 아래 x 자리를 계산한 값으로 바꾼다. 폭은 그대로 두고 값만 적는다.
//   4. make test 를 실행한다. UNANSWERED 는 아직 x 인 항목, FAIL 은 계산이 다른 항목이다.
//
// 표기 예: 8'h3c  16'h1234  1'b1  2'd3  5 (10진수 항목)

// CH06  ex03_generate WIDTH=8: sum, carry_out, 하위 4비트에서 올라오는 자리올림
`define P_CH06_SUM             8'bx
`define P_CH06_CARRY_OUT       1'bx
`define P_CH06_MID_CARRY       1'bx

// CH07  메모리 읽기 시점 3개와 FSM 관찰 2개
`define P_CH07_COMB_AFTER_2    8'bx
`define P_CH07_SYNC_AFTER_2    8'bx
`define P_CH07_SYNC_AFTER_3    8'bx
`define P_CH07_DETECT_COUNT    32'bx    // 10진수. 에지 8개 가운데 detected=1 인 횟수
`define P_CH07_FINAL_STATE     2'bx     // IDLE=0 SAW_ONE=1 SAW_TWO=2 SAW_MANY=3

// CH08  누적기에 x1, x2 를 연속으로 더한 뒤의 값
`define P_CH08_TOTAL1          16'bx
`define P_CH08_TOTAL2          16'bx
`define P_CH08_ZERO2           1'bx
`define P_CH08_CARRY2          1'bx

// CH09  ex01_synthesizable WIDTH=8: 연산 3단계 뒤의 result 와 is_zero
`define P_CH09_RESULT          8'bx
`define P_CH09_IS_ZERO         1'bx

// CH10  mux_systemverilog 출력, dff_systemverilog 의 에지별 q
`define P_CH10_MUX_Y           8'bx
`define P_CH10_Q_AFTER_1       8'bx
`define P_CH10_Q_AFTER_2       8'bx
