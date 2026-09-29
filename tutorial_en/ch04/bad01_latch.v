// 의도적 함정 1. 조합 블록에서 일부 경로의 배정을 빠뜨린다.
// 합성기는 값을 유지하는 소자를 만든다. 이것을 latch 추론이라고 한다.
// 시뮬레이션에서는 이전 값이 그대로 남는 현상으로 나타난다.
`timescale 1ns/1ps

module leaky_mux(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire       sel,
  output reg  [7:0] y
);
  always @* begin
    if (sel)
      y = in1;
    // sel이 0인 경로에 배정이 빠져 있다.
  end
endmodule

module bad01_latch;
  reg  [7:0] in0, in1;
  reg        sel;
  wire [7:0] y;

  leaky_mux dut(.in0(in0), .in1(in1), .sel(sel), .y(y));

  initial begin
    in0 = 8'haa; in1 = 8'hbb;

    sel = 1'b1; #1;
    $display("sel=1 -> y=%h  in1이 전달된다", y);

    sel = 1'b0; #1;
    $display("sel=0 -> y=%h  in0 대신 이전 값이 남는다", y);

    in1 = 8'hcc;
    sel = 1'b1; #1;
    $display("sel=1 -> y=%h", y);

    sel = 1'b0; #1;
    $display("sel=0 -> y=%h  값이 계속 따라온다", y);

    $finish(0);
  end
endmodule
