// 예제 7-4. 유한 상태 기계. 입력에서 연속된 1을 3개 찾으면 신호를 낸다.
// 상태 저장과 상태 전이를 블록 2개로 나누는 형태다.
`timescale 1ns/1ps

module ex04_fsm(
  input  wire clk,
  input  wire reset,
  input  wire bit_in,
  output reg  detected
);

  // 상태 이름을 localparam으로 정한다. 숫자를 코드에 직접 적는 방식보다 읽기 쉽다.
  localparam [1:0] IDLE     = 2'd0;
  localparam [1:0] SAW_ONE  = 2'd1;
  localparam [1:0] SAW_TWO  = 2'd2;
  localparam [1:0] SAW_MANY = 2'd3;

  reg [1:0] state, next_state;

  // 블록 1. 상태 저장. 순차 논리다.
  always @(posedge clk) begin
    if (reset)
      state <= IDLE;
    else
      state <= next_state;
  end

  // 블록 2. 상태 전이와 출력. 조합 논리다.
  always @* begin
    next_state = state;      // 기본값은 현재 상태 유지
    detected   = 1'b0;       // 기본값은 신호 없음

    case (state)
      IDLE: begin
        if (bit_in) next_state = SAW_ONE;
      end
      SAW_ONE: begin
        if (bit_in) next_state = SAW_TWO;
        else        next_state = IDLE;
      end
      SAW_TWO: begin
        if (bit_in) next_state = SAW_MANY;
        else        next_state = IDLE;
      end
      SAW_MANY: begin
        detected = 1'b1;                  // 출력이 상태만으로 정해진다
        if (bit_in) next_state = SAW_MANY;
        else        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

endmodule
