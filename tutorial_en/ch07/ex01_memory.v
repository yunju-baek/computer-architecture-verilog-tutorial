// 예제 7-1. 배열로 저장 공간을 만든다.
// 동기 쓰기와 조합 읽기를 갖춘 형태다.
`timescale 1ns/1ps

module ex01_memory #(
  parameter ADDR_WIDTH = 4,                 // 주소 폭
  parameter DATA_WIDTH = 8                  // 데이터 폭
)(
  input  wire                  clk,
  input  wire                  write_enable,
  input  wire [ADDR_WIDTH-1:0] write_addr,
  input  wire [DATA_WIDTH-1:0] write_data,
  input  wire [ADDR_WIDTH-1:0] read_addr,
  output wire [DATA_WIDTH-1:0] read_data
);

  localparam DEPTH = 1 << ADDR_WIDTH;       // 주소 폭이 정하는 칸 수

  // 배열 선언. 폭은 앞에, 칸 수는 이름 뒤에 적는다.
  reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];

  // 동기 쓰기. clock 에지에서 한 칸을 갱신한다.
  always @(posedge clk) begin
    if (write_enable)
      storage[write_addr] <= write_data;
  end

  // 조합 읽기. 주소가 바뀌면 곧바로 값이 나온다.
  assign read_data = storage[read_addr];

endmodule
