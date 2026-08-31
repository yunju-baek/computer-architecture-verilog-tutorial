// 예제 10-1의 testbench. Verilog 모듈과 SystemVerilog 모듈을 한 환경에서 연결한다.
`timescale 1ns/1ps

module tb_ex01;

  // testbench는 SystemVerilog 표기를 쓴다.
  logic       clk = 1'b0;
  logic       reset;
  logic [7:0] a, b, d;
  logic       sel;
  logic [7:0] mux_v, mux_sv, dff_v, dff_sv;
  int         i;                    // int는 SystemVerilog의 32비트 정수형이다

  // Verilog-2001 모듈을 SystemVerilog testbench에서 instance로 만든다.
  mux_verilog2001    u_mux_v (.a(a), .b(b), .sel(sel), .y(mux_v));
  mux_systemverilog  u_mux_sv(.a(a), .b(b), .sel(sel), .y(mux_sv));
  dff_verilog2001    u_dff_v (.clk(clk), .reset(reset), .d(d), .q(dff_v));
  dff_systemverilog  u_dff_sv(.clk(clk), .reset(reset), .d(d), .q(dff_sv));

  always #5 clk = ~clk;

  initial begin
    $display("--- 조합 논리 대조 ---");
    a = 8'haa; b = 8'hbb;
    for (i = 0; i < 2; i++) begin      // ++ 는 SystemVerilog 표기다
      sel = i[0];
      #1;
      $display("sel=%b -> Verilog %h, SystemVerilog %h", sel, mux_v, mux_sv);
      if (mux_v !== mux_sv) $fatal(1, "FAIL 조합 논리가 갈라졌다 sel=%b", sel);
    end

    $display("--- 순차 논리 대조 ---");
    reset = 1'b1; d = 8'hff;
    @(posedge clk); #1;
    $display("reset 뒤 -> Verilog %h, SystemVerilog %h", dff_v, dff_sv);
    if (dff_v !== dff_sv) $fatal(1, "FAIL 리셋이 갈라졌다");

    reset = 1'b0; d = 8'h5a;
    @(posedge clk); #1;
    $display("d=5a 뒤  -> Verilog %h, SystemVerilog %h", dff_v, dff_sv);
    if (dff_v !== dff_sv) $fatal(1, "FAIL 갱신이 갈라졌다");
    if (dff_v !== 8'h5a)  $fatal(1, "FAIL dff_v=%h", dff_v);

    $display("두 표기가 같은 회로를 만든다");
    $display("PASS ch10 ex01 표기 대조");
    $finish(0);
  end

endmodule
