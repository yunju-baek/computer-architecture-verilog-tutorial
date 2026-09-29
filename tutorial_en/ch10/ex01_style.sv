// 예제 10-1. 같은 회로를 두 문법으로 쓴다.
// 위쪽이 이 자습서 본문의 Verilog-2001 표기, 아래쪽이 제공 testbench의 SystemVerilog 표기다.
`timescale 1ns/1ps

// Verilog-2001 표기
module mux_verilog2001(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] y
);
  always @* begin
    y = a;
    if (sel) y = b;
  end
endmodule

// SystemVerilog 표기
module mux_systemverilog(
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic       sel,
  output logic [7:0] y
);
  always_comb begin
    y = a;
    if (sel) y = b;
  end
endmodule

// 순차 논리도 같은 방식으로 대응한다.
module dff_verilog2001(
  input  wire       clk,
  input  wire       reset,
  input  wire [7:0] d,
  output reg  [7:0] q
);
  always @(posedge clk) begin
    if (reset) q <= 8'h00;
    else       q <= d;
  end
endmodule

module dff_systemverilog(
  input  logic       clk,
  input  logic       reset,
  input  logic [7:0] d,
  output logic [7:0] q
);
  always_ff @(posedge clk) begin
    if (reset) q <= 8'h00;
    else       q <= d;
  end
endmodule
