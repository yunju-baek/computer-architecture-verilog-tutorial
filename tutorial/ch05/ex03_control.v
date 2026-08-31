// 예제 5-3. reset, load, enable의 우선순위는 if 연쇄의 순서가 정한다.
// HW03의 프로그램 카운터가 이 형태다.
`timescale 1ns/1ps

module ex03_control(
  input  wire        clk,
  input  wire        reset,      // 최우선. 상태를 시작값으로 되돌린다
  input  wire        load,       // 다음 순위. 외부 값을 받아들인다
  input  wire        enable,     // 마지막. 스스로 진행한다
  input  wire [31:0] load_value,
  output reg  [31:0] state
);

  always @(posedge clk) begin
    if (reset)
      state <= 32'h0000_0000;
    else if (load)
      state <= load_value;
    else if (enable)
      state <= state + 32'd4;    // 워드 단위로 진행한다
    // 세 조건이 모두 거짓이면 state가 값을 유지한다.
    // 순차 블록에서 값 유지는 의도한 동작이므로 이 형태를 그대로 쓴다.
  end

endmodule
