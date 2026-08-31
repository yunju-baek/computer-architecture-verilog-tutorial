// 의도적 오류 1. 같은 reg를 always 블록 2개에서 대입한다.
// 구동원이 2개이므로 값이 정해지는 순서에 따라 결과가 달라진다.
`timescale 1ns/1ps

module conflicting_state(
  input  wire       clk,
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] state
);
  always @(posedge clk) begin
    state <= a;      // 구동원 1
  end

  always @(posedge clk) begin
    state <= b;      // 구동원 2
  end
endmodule

module bad01_two_always;
  reg        clk = 1'b0;
  reg  [7:0] a, b;
  wire [7:0] state;

  conflicting_state dut(.clk(clk), .a(a), .b(b), .state(state));

  always #5 clk = ~clk;

  initial begin
    a = 8'haa; b = 8'hbb;
    @(posedge clk); #1;
    $display("a=%h b=%h -> state=%h", a, b, state);
    $display("어느 값이 남는지는 시뮬레이터의 블록 실행 순서가 정한다");
    @(posedge clk); #1;
    $display("두 번째 에지 -> state=%h", state);
    $finish(0);
  end
endmodule
