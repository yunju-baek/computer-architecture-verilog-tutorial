// 예제 7-2. 조합 읽기와 동기 읽기의 차이
`timescale 1ns/1ps

// 조합 읽기. 주소를 넣은 시각에 값이 나온다.
module comb_read_memory(
  input  wire       clk,
  input  wire       write_enable,
  input  wire [3:0] addr,
  input  wire [7:0] write_data,
  output wire [7:0] read_data
);
  reg [7:0] storage [0:15];

  always @(posedge clk) begin
    if (write_enable) storage[addr] <= write_data;
  end

  assign read_data = storage[addr];
endmodule

// 동기 읽기. 주소를 clock 에지에 잡고 다음 사이클에 값이 나온다.
module sync_read_memory(
  input  wire       clk,
  input  wire       write_enable,
  input  wire [3:0] addr,
  input  wire [7:0] write_data,
  output reg  [7:0] read_data
);
  reg [7:0] storage [0:15];

  always @(posedge clk) begin
    if (write_enable) storage[addr] <= write_data;
    read_data <= storage[addr];      // 출력이 레지스터를 지난다
  end
endmodule
