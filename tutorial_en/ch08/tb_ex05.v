// 예제 8-5. 증거 파일 만들기.
// VCD 파형과 CSV trace를 함께 남긴다. 과제 제출물이 이 형태다.
`timescale 1ns/1ps

module tb_ex05;

  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  integer     trace_file;      // 파일 핸들
  integer     cycle;
  integer     step;

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  // 사이클 번호를 세는 블록
  always @(posedge clk) begin
    if (reset) cycle <= 0;
    else       cycle <= cycle + 1;
  end

  initial begin
    $timeformat(-9, 0, "ns", 6);

    // 1. VCD 파형 기록을 켠다.
    $dumpfile("build/ex05.vcd");
    $dumpvars(0, tb_ex05);        // 0은 이 모듈 아래 전체 계층을 뜻한다

    // 2. CSV 파일을 열고 머리글을 적는다.
    trace_file = $fopen("build/trace.csv", "w");
    if (trace_file == 0) $fatal(1, "FAIL trace.csv를 열지 못했다");
    // CSV에는 %0t 대신 %0d를 쓴다. %0t는 $timeformat이 붙인 단위 문자를 함께 낸다.
    // $time을 %0d로 내면 `timescale의 시간 단위인 ns 값이 나온다.
    $fwrite(trace_file, "cycle,time_ns,enable,addend,total,zero,carry\n");

    cycle  = 0;
    reset  = 1'b1; enable = 1'b0; addend = 16'h0;
    @(posedge clk); #1;
    reset = 1'b0;

    $display("cycle | addend total zero carry");
    $display("------+-----------------------");

    for (step = 0; step < 6; step = step + 1) begin
      enable = 1'b1;
      addend = 16'h3000 + step[15:0];
      @(posedge clk); #1;

      // 3. 한 줄씩 기록한다. enable을 내리기 전에 적어 그 사이클의 값을 남긴다.
      $fwrite(trace_file, "%0d,%0d,%b,%h,%h,%b,%b\n",
              cycle, $time, enable, addend, total, zero, carry);
      $display("  %0d   |  %h   %h    %b     %b", cycle, addend, total, zero, carry);

      enable = 1'b0;
    end

    // 4. 파일을 닫는다. 닫지 않으면 내용이 남지 않을 여지가 있다.
    $fclose(trace_file);

    $display("build/ex05.vcd 와 build/trace.csv 를 남겼다");
    $display("PASS ch08 ex05 증거 파일");
    $finish(0);
  end

endmodule
