// 의도적 함정 2. 순차 블록에서 블로킹 대입을 쓴다.
// 블록 안의 문장 순서가 회로 동작을 바꾼다.
`timescale 1ns/1ps

// 문장 순서 1. 먼저 q0에 대입한 뒤 q1이 그것을 읽는다.
module order_first(
  input  wire clk,
  input  wire d,
  output reg  q0,
  output reg  q1
);
  always @(posedge clk) begin
    q0 = d;
    q1 = q0;
  end
endmodule

// 문장 순서 2. 순서를 뒤집었다.
module order_second(
  input  wire clk,
  input  wire d,
  output reg  q0,
  output reg  q1
);
  always @(posedge clk) begin
    q1 = q0;
    q0 = d;
  end
endmodule

// 논블로킹 대입은 문장 순서와 무관하게 같은 회로가 된다.
module order_nonblocking(
  input  wire clk,
  input  wire d,
  output reg  q0,
  output reg  q1
);
  always @(posedge clk) begin
    q1 <= q0;
    q0 <= d;
  end
endmodule

module bad02_blocking_seq;
  reg  clk = 1'b0;
  reg  d;
  wire f0, f1, s0, s1, n0, n1;
  integer cycle;

  order_first       u_first (.clk(clk), .d(d), .q0(f0), .q1(f1));
  order_second      u_second(.clk(clk), .d(d), .q0(s0), .q1(s1));
  order_nonblocking u_nb    (.clk(clk), .d(d), .q0(n0), .q1(n1));

  always #5 clk = ~clk;

  initial begin
    d = 1'b0;
    repeat (3) @(posedge clk);
    #1;

    $display("cycle d | 순서1 q1 q0 | 순서2 q1 q0 | 논블로킹 q1 q0");
    $display("------+------------+------------+---------------");
    for (cycle = 0; cycle < 4; cycle = cycle + 1) begin
      d = (cycle == 0) ? 1'b1 : 1'b0;
      @(posedge clk); #1;
      $display("  %0d   %b |    %b  %b     |    %b  %b     |      %b  %b",
               cycle, d, f1, f0, s1, s0, n1, n0);
    end
    $display("블로킹 대입은 문장 순서가 회로를 바꾸고 논블로킹은 순서2와 같은 회로가 된다");
    $finish(0);
  end
endmodule
