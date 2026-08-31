// 예제 5-1의 testbench. clock을 만들고 에지 전후의 값을 관찰한다.
`timescale 1ns/1ps

module tb_ex01;

  reg        clk = 1'b0;
  reg        reset;
  reg  [7:0] d;
  wire [7:0] q;

  ex01_dff dut(.clk(clk), .reset(reset), .d(d), .q(q));

  // 주기 10ns clock. 5ns마다 반전한다.
  always #5 clk = ~clk;

  initial begin
    // 시각을 ns 단위로 표시한다.
    $timeformat(-9, 0, "ns", 6);

    $display("  시각 reset d    q");
    $display("------------------");

    // 리셋을 걸고 첫 에지를 지난다.
    reset = 1'b1; d = 8'hff;
    @(posedge clk); #1;
    $display("%t   %b   %h   %h  리셋이 우선한다", $time, reset, d, q);
    if (q !== 8'h00) $fatal(1, "FAIL 리셋 후 q=%h", q);

    // 리셋을 풀고 값을 넣는다.
    reset = 1'b0; d = 8'haa;
    @(posedge clk); #1;
    $display("%t   %b   %h   %h  d가 q로 옮겨진다", $time, reset, d, q);
    if (q !== 8'haa) $fatal(1, "FAIL q=%h", q);

    // 에지 사이에 d를 바꿔도 q는 그대로다.
    d = 8'hbb;
    #1;
    $display("%t   %b   %h   %h  에지 앞에서는 q가 유지된다", $time, reset, d, q);
    if (q !== 8'haa) $fatal(1, "FAIL 에지 앞 q=%h", q);

    @(posedge clk); #1;
    $display("%t   %b   %h   %h  에지에서 갱신된다", $time, reset, d, q);
    if (q !== 8'hbb) $fatal(1, "FAIL q=%h", q);

    // 에지 직전에 값을 바꾸면 그 값이 잡힌다.
    d = 8'hcc;
    @(posedge clk); #1;
    $display("%t   %b   %h   %h", $time, reset, d, q);
    if (q !== 8'hcc) $fatal(1, "FAIL q=%h", q);

    $display("PASS ch05 ex01 dff");
    $finish(0);
  end

endmodule
