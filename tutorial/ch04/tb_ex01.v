// 예제 4-1의 testbench.
`timescale 1ns/1ps

module tb_ex01;

  reg  [7:0] in0, in1, in2, in3;
  reg  [1:0] sel;
  wire [7:0] y;
  integer    i;

  ex01_mux4 dut(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel), .y(y));

  initial begin
    in0 = 8'haa; in1 = 8'hbb; in2 = 8'hcc; in3 = 8'hdd;

    $display("sel | y");
    $display("----+----");
    for (i = 0; i < 4; i = i + 1) begin
      sel = i[1:0];
      #1;
      $display(" %b | %h", sel, y);
    end

    sel = 2'b00; #1; if (y !== 8'haa) $fatal(1, "FAIL sel=00 y=%h", y);
    sel = 2'b01; #1; if (y !== 8'hbb) $fatal(1, "FAIL sel=01 y=%h", y);
    sel = 2'b10; #1; if (y !== 8'hcc) $fatal(1, "FAIL sel=10 y=%h", y);
    sel = 2'b11; #1; if (y !== 8'hdd) $fatal(1, "FAIL sel=11 y=%h", y);

    // sel에 x가 섞이면 default 경로가 선택된다.
    sel = 2'bx0; #1;
    $display("sel=x0 -> y=%h  default 경로가 값을 정한다", y);

    $display("PASS ch04 ex01 mux4");
    $finish(0);
  end

endmodule
