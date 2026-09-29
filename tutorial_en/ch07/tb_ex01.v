// 예제 7-1의 testbench.
`timescale 1ns/1ps

module tb_ex01;

  reg        clk = 1'b0;
  reg        write_enable;
  reg  [3:0] write_addr, read_addr;
  reg  [7:0] write_data;
  wire [7:0] read_data;
  integer    i;

  ex01_memory #(.ADDR_WIDTH(4), .DATA_WIDTH(8)) dut(
    .clk(clk), .write_enable(write_enable),
    .write_addr(write_addr), .write_data(write_data),
    .read_addr(read_addr), .read_data(read_data)
  );

  always #5 clk = ~clk;

  task write_cell;
    input [3:0] addr;
    input [7:0] data;
    begin
      write_enable = 1'b1;
      write_addr   = addr;
      write_data   = data;
      @(posedge clk);
      #1;
      write_enable = 1'b0;
    end
  endtask

  initial begin
    write_enable = 1'b0;

    // 칸 16개를 채운다. 주소에 0x10을 더한 값을 넣는다.
    for (i = 0; i < 16; i = i + 1)
      write_cell(i[3:0], i[3:0] + 8'h10);

    $display("--- 조합 읽기는 주소가 바뀌면 곧바로 값을 낸다 ---");
    $display("addr | data");
    $display("-----+-----");
    for (i = 0; i < 16; i = i + 1) begin
      read_addr = i[3:0];
      #1;
      if (i < 5)
        $display("  %h  |  %h", read_addr, read_data);
      if (read_data !== (i[3:0] + 8'h10))
        $fatal(1, "FAIL addr=%h data=%h expected=%h",
               read_addr, read_data, i[3:0] + 8'h10);
    end

    $display("--- write_enable이 0이면 값을 유지한다 ---");
    read_addr    = 4'h3;
    write_enable = 1'b0;
    write_addr   = 4'h3;
    write_data   = 8'hff;
    @(posedge clk); #1;
    $display("write_enable=0 -> addr 3 data=%h", read_data);
    if (read_data !== 8'h13) $fatal(1, "FAIL 유지 data=%h", read_data);

    $display("--- 배열 원소를 계층 이름으로 직접 읽는다 ---");
    $display("dut.storage[7] = %h", dut.storage[7]);

    $display("PASS ch07 ex01 memory");
    $finish(0);
  end

endmodule
