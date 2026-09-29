// 예제 7-2의 testbench. 값이 나오는 시점을 대조한다.
`timescale 1ns/1ps

module tb_ex02;

  reg        clk = 1'b0;
  reg        write_enable;
  reg  [3:0] addr;
  reg  [7:0] write_data;
  wire [7:0] comb_data;
  wire [7:0] sync_data;
  integer    i;

  comb_read_memory u_comb(.clk(clk), .write_enable(write_enable), .addr(addr),
                          .write_data(write_data), .read_data(comb_data));
  sync_read_memory u_sync(.clk(clk), .write_enable(write_enable), .addr(addr),
                          .write_data(write_data), .read_data(sync_data));

  always #5 clk = ~clk;

  initial begin
    $timeformat(-9, 0, "ns", 6);

    // 두 메모리에 같은 값을 채운다.
    write_enable = 1'b1;
    for (i = 0; i < 4; i = i + 1) begin
      addr       = i[3:0];
      write_data = 8'ha0 + i[7:0];
      @(posedge clk); #1;
    end
    write_enable = 1'b0;

    $display("  시각 addr | 조합 동기");
    $display("-----------+----------");

    addr = 4'h0; #1;
    $display("%t   %h  |  %h   %h  주소를 넣은 직후", $time, addr, comb_data, sync_data);

    @(posedge clk); #1;
    $display("%t   %h  |  %h   %h  에지를 지난 뒤", $time, addr, comb_data, sync_data);
    if (comb_data !== 8'ha0) $fatal(1, "FAIL comb_data=%h", comb_data);
    if (sync_data !== 8'ha0) $fatal(1, "FAIL sync_data=%h", sync_data);

    addr = 4'h2; #1;
    $display("%t   %h  |  %h   %h  주소를 바꾼 직후", $time, addr, comb_data, sync_data);
    if (comb_data !== 8'ha2) $fatal(1, "FAIL comb_data=%h", comb_data);
    if (sync_data !== 8'ha0) $fatal(1, "FAIL 동기 읽기는 아직 이전 값이다 sync=%h", sync_data);

    @(posedge clk); #1;
    $display("%t   %h  |  %h   %h  에지를 지난 뒤", $time, addr, comb_data, sync_data);
    if (sync_data !== 8'ha2) $fatal(1, "FAIL sync_data=%h", sync_data);

    $display("동기 읽기는 주소를 넣은 다음 사이클에 값을 낸다");
    $display("PASS ch07 ex02 sync read");
    $finish(0);
  end

endmodule
