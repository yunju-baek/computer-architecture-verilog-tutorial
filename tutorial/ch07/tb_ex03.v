// 예제 7-3의 testbench.
`timescale 1ns/1ps

module tb_ex03;

  reg  [2:0]  addr;
  wire [31:0] data;
  integer     i;

  ex03_readmem #(.DEPTH(8), .INIT_FILE("program.hex")) dut(.addr(addr), .data(data));

  initial begin
    #1;
    $display("addr | data      해석");
    $display("-----+---------------------------");
    for (i = 0; i < 8; i = i + 1) begin
      addr = i[2:0];
      #1;
      $display("  %0d  | %h", addr, data);
    end

    addr = 3'd0; #1;
    if (data !== 32'h0050_0093) $fatal(1, "FAIL addr 0 data=%h", data);
    addr = 3'd2; #1;
    if (data !== 32'h0020_81B3) $fatal(1, "FAIL addr 2 data=%h", data);
    addr = 3'd4; #1;
    if (data !== 32'hDEAD_BEEF) $fatal(1, "FAIL addr 4 data=%h", data);

    // 파일 범위를 넘는 주소는 미리 채운 0이 남는다.
    addr = 3'd5; #1;
    if (data !== 32'h0000_0000) $fatal(1, "FAIL addr 5 data=%h", data);
    $display("파일에 담긴 워드 수는 5이고 주소 5부터는 미리 채운 0이 남는다");

    $display("PASS ch07 ex03 readmem");
    $finish(0);
  end

endmodule
