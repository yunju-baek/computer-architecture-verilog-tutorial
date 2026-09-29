// 예제 5-2의 testbench. 두 방식의 동작 차이를 사이클마다 대조한다.
`timescale 1ns/1ps

module tb_ex02;

  reg  clk = 1'b0;
  reg  d;
  wire n0, n1, n2;    // 논블로킹 결과
  wire b0, b1, b2;    // 블로킹 결과
  integer cycle;

  shift_nonblocking u_nb(.clk(clk), .d(d), .q0(n0), .q1(n1), .q2(n2));
  shift_blocking    u_b (.clk(clk), .d(d), .q0(b0), .q1(b1), .q2(b2));

  always #5 clk = ~clk;

  initial begin
    // 두 모듈의 초기 상태를 0으로 맞춘다.
    d = 1'b0;
    repeat (4) @(posedge clk);
    #1;

    $display("cycle d | nonblocking q2 q1 q0 | blocking q2 q1 q0");
    $display("------+---------------------+------------------");

    // 1 하나를 넣고 3사이클 동안 이동을 관찰한다.
    for (cycle = 0; cycle < 5; cycle = cycle + 1) begin
      d = (cycle == 0) ? 1'b1 : 1'b0;
      @(posedge clk); #1;
      $display("  %0d   %b |        %b  %b  %b     |      %b  %b  %b",
               cycle, d, n2, n1, n0, b2, b1, b0);
    end

    $display("논블로킹은 값이 한 단씩 이동하고 블로킹은 한 사이클에 끝까지 통과한다");
    $finish(0);
  end

endmodule
