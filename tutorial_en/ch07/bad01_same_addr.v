// 의도적 함정 1. 같은 주소에 쓰면서 동시에 읽는다.
// 읽기 방식에 따라 새 값과 이전 값 가운데 어느 쪽이 나오는지 갈라진다.
`timescale 1ns/1ps

module read_write_memory(
  input  wire       clk,
  input  wire       write_enable,
  input  wire [3:0] addr,
  input  wire [7:0] write_data,
  output wire [7:0] comb_read,      // 조합 읽기
  output reg  [7:0] sync_read       // 동기 읽기
);
  reg [7:0] storage [0:15];

  always @(posedge clk) begin
    if (write_enable) storage[addr] <= write_data;
    sync_read <= storage[addr];
  end

  assign comb_read = storage[addr];
endmodule

module bad01_same_addr;
  reg        clk = 1'b0;
  reg        write_enable;
  reg  [3:0] addr;
  reg  [7:0] write_data;
  wire [7:0] comb_read;
  wire [7:0] sync_read;

  read_write_memory dut(.clk(clk), .write_enable(write_enable), .addr(addr),
                        .write_data(write_data), .comb_read(comb_read),
                        .sync_read(sync_read));

  always #5 clk = ~clk;

  initial begin
    $timeformat(-9, 0, "ns", 6);

    // 주소 5에 이전 값을 넣는다.
    addr = 4'h5; write_data = 8'h11; write_enable = 1'b1;
    @(posedge clk); #1;
    write_enable = 1'b0;
    @(posedge clk); #1;
    $display("준비 완료. 주소 5의 값은 %h다", comb_read);

    // 같은 주소에 새 값을 쓰면서 읽는다.
    write_data = 8'h99; write_enable = 1'b1;
    @(posedge clk); #1;
    write_enable = 1'b0;
    $display("같은 에지에 쓰기와 읽기를 함께 했다");
    $display("조합 읽기 -> %h  새 값이 곧바로 보인다", comb_read);
    $display("동기 읽기 -> %h  이 에지 이전의 값이 잡혔다", sync_read);

    @(posedge clk); #1;
    $display("다음 에지 -> 동기 읽기 %h", sync_read);
    $finish(0);
  end
endmodule
