// 예제 9-1. 합성 가능한 구조만 써서 만든 모듈.
// 이 자습서가 다룬 문법 가운데 합성 대상에 쓸 수 있는 것을 모았다.
`timescale 1ns/1ps

module ex01_synthesizable #(
  parameter WIDTH = 8                      // 파라미터
)(
  input  wire             clk,
  input  wire             reset,
  input  wire             enable,
  input  wire [1:0]       operation,
  input  wire [WIDTH-1:0] operand,
  output reg  [WIDTH-1:0] result,
  output wire             is_zero
);

  localparam [1:0] OP_ADD = 2'd0,        // 상태와 연산 인코딩
                   OP_SUB = 2'd1,
                   OP_AND = 2'd2,
                   OP_OR  = 2'd3;

  reg [WIDTH-1:0] next_result;            // 중간 신호

  // 조합 논리. 기본값 선행 배정과 default를 갖춘다.
  always @* begin
    next_result = result;
    case (operation)
      OP_ADD:  next_result = result + operand;
      OP_SUB:  next_result = result - operand;
      OP_AND:  next_result = result & operand;
      default: next_result = result | operand;
    endcase
  end

  // 순차 논리. 동기 리셋과 논블로킹 대입을 쓴다.
  always @(posedge clk) begin
    if (reset)
      result <= {WIDTH{1'b0}};
    else if (enable)
      result <= next_result;
  end

  // 연속 할당과 reduction 연산자
  assign is_zero = ~|result;

endmodule
