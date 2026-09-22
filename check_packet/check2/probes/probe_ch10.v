// 점검 2-5. CH10 SystemVerilog 표기 읽기. always_comb mux 와 always_ff dff 의 출력을 예상한다.
// 대상: tutorial/ch10/ex01_style.sv (mux_systemverilog, dff_systemverilog)
//
// 입력은 하강 에지에 바꾸고, 상승 에지 뒤 #1에서 값을 읽는다.
`timescale 1ns/1ps

module probe_ch10;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3, s4, s5;
  reg         clk = 1'b0;
  reg  [7:0]  a, b;
  reg         sel;
  wire [7:0]  y;
  reg         reset;
  reg  [7:0]  d;
  wire [7:0]  q;
  reg  [7:0]  d1, d2;
  reg  [7:0]  q_after_1, q_after_2;
  integer     fails;

  mux_systemverilog mux(.a(a), .b(b), .sel(sel), .y(y));
  dff_systemverilog dff(.clk(clk), .reset(reset), .d(d), .q(q));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk); #1;
    end
  endtask

  initial begin
    fails = 0;
    read_student_id(sid);

    // 입력 파생: salt 0x5A5A0A00
    s1 = lcg_next(sid ^ 32'h5A5A0A00);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    s4 = lcg_next(s3);
    s5 = lcg_next(s4);
    a   = s1[31:24];
    b   = s2[31:24];
    sel = s3[31];
    d1  = s4[31:24];
    d2  = s5[31:24];

    $display("=== probe_ch10 STUDENT_ID=%0d ===", sid);
    $display("INPUT mux_systemverilog: a=%h b=%h sel=%b", a, b, sel);
    $display("INPUT dff_systemverilog: reset 1에지 뒤  에지1: reset=0 d=%h   에지2: reset=1 d=%h", d1, d2);
    #1;

    @(negedge clk);
    reset = 1'b1; d = 8'h00;
    step;
    @(negedge clk);
    reset = 1'b0; d = d1;
    step;
    q_after_1 = q;
    @(negedge clk);
    reset = 1'b1; d = d2;
    step;
    q_after_2 = q;

    `CHECK("CH10_MUX_Y",     `P_CH10_MUX_Y,     y)
    `CHECK("CH10_Q_AFTER_1", `P_CH10_Q_AFTER_1, q_after_1)
    `CHECK("CH10_Q_AFTER_2", `P_CH10_Q_AFTER_2, q_after_2)
    `FINISH_CHECK("ch10", sid)
  end
endmodule
