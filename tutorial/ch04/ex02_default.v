// 예제 4-2. 기본값 선행 배정. 조합 블록의 출력을 모든 경로에서 확정한다.
`timescale 1ns/1ps

// 방식 1. 블록 첫 줄에서 모든 출력에 기본값을 준 뒤 필요한 곳만 덮어쓴다.
module with_default(
  input  wire [3:0] opcode,
  output reg  [1:0] alu_select,
  output reg        write_enable,
  output reg        memory_read,
  output reg        illegal
);
  always @* begin
    // 기본값을 먼저 배정한다. 이 4줄이 모든 경로의 값을 확정한다.
    alu_select   = 2'b00;
    write_enable = 1'b0;
    memory_read  = 1'b0;
    illegal      = 1'b0;

    case (opcode)
      4'h1: begin alu_select = 2'b00; write_enable = 1'b1;                     end
      4'h2: begin alu_select = 2'b01; write_enable = 1'b1;                     end
      4'h3: begin alu_select = 2'b10; write_enable = 1'b1; memory_read = 1'b1; end
      4'h4: begin                     write_enable = 1'b1;                     end
      default: illegal = 1'b1;
    endcase
  end
endmodule

// 방식 2. 모든 분기에서 모든 출력을 각각 배정한다.
module with_full_branches(
  input  wire [3:0] opcode,
  output reg  [1:0] alu_select,
  output reg        write_enable,
  output reg        memory_read,
  output reg        illegal
);
  always @* begin
    case (opcode)
      4'h1: begin alu_select = 2'b00; write_enable = 1'b1; memory_read = 1'b0; illegal = 1'b0; end
      4'h2: begin alu_select = 2'b01; write_enable = 1'b1; memory_read = 1'b0; illegal = 1'b0; end
      4'h3: begin alu_select = 2'b10; write_enable = 1'b1; memory_read = 1'b1; illegal = 1'b0; end
      4'h4: begin alu_select = 2'b00; write_enable = 1'b1; memory_read = 1'b0; illegal = 1'b0; end
      default: begin alu_select = 2'b00; write_enable = 1'b0; memory_read = 1'b0; illegal = 1'b1; end
    endcase
  end
endmodule
