// 점검 1 예상값 기록 파일. make test 가 이 값을 실제 실행 결과와 비교한다.
//
// 작성 방법
//   1. make show-inputs 로 자신의 학번에서 파생된 입력값을 본다.
//   2. 해당 장의 원본 소스를 읽고 출력을 손으로 계산한다.
//   3. 아래 x 자리를 계산한 값으로 바꾼다. 폭은 그대로 두고 값만 적는다.
//   4. make test 를 실행한다. UNANSWERED 는 아직 x 인 항목, FAIL 은 계산이 다른 항목이다.
//
// 표기 예: 4'b1010  7'h33  5'd9  1'b1  32'h0000_1234  -3 (10진수 항목)

// CH01  ex02_inverter: y = ~a
`define P_CH01_Y               4'bx

// CH02  ex04_select: 명령어 워드에서 자른 필드
`define P_CH02_OPCODE          7'bx
`define P_CH02_RD              5'bx
`define P_CH02_FUNCT3          3'bx
`define P_CH02_RS1             5'bx
`define P_CH02_RS2             5'bx
`define P_CH02_FUNCT7          7'bx

// CH03  ex02_width_rules: a + b 를 4비트와 5비트에 담은 결과, 자리올림, a의 signed 해석(10진수)
`define P_CH03_NARROW_SUM      4'bx
`define P_CH03_WIDE_SUM        5'bx
`define P_CH03_CARRY           1'bx
`define P_CH03_A_SIGNED        32'bx

// CH04  with_default 디코더 출력 4개와 ex01_mux4 출력
`define P_CH04_ALU_SELECT      2'bx
`define P_CH04_WRITE_ENABLE    1'bx
`define P_CH04_MEMORY_READ     1'bx
`define P_CH04_ILLEGAL         1'bx
`define P_CH04_MUX_Y           8'bx

// CH05  ex03_control 의 단계별 state, shift_nonblocking 의 {q0,q1,q2}
`define P_CH05_AFTER_LOAD        32'bx
`define P_CH05_AFTER_ENABLE      32'bx
`define P_CH05_AFTER_RESET_LOAD  32'bx
`define P_CH05_SHIFT_Q0Q1Q2      3'bx
