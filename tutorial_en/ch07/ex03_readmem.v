// 예제 7-3. $readmemh로 메모리를 파일에서 초기화한다.
// 명령어 메모리를 준비하는 표준 방식이다.
`timescale 1ns/1ps

module ex03_readmem #(
  parameter DEPTH     = 8,
  parameter INIT_FILE = "program.hex"
)(
  input  wire [2:0]  addr,
  output wire [31:0] data
);

  reg [31:0] instruction_memory [0:DEPTH-1];
  integer    index;

  // initial 블록으로 초기값을 채운다. 시뮬레이션 시작 시각에 한 번 실행된다.
  initial begin
    // 파일에 담긴 워드 수가 DEPTH보다 적을 수 있으므로 먼저 0으로 채운다.
    for (index = 0; index < DEPTH; index = index + 1)
      instruction_memory[index] = 32'h0000_0000;

    $readmemh(INIT_FILE, instruction_memory);
  end

  assign data = instruction_memory[addr];

endmodule
