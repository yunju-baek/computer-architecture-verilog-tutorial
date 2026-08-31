// 의도적 함정 2. 기대값 없이 출력만 남기는 testbench.
// 결함이 있어도 통과처럼 보인다.
`timescale 1ns/1ps

// 결함을 심은 누적기. enable 확인을 빠뜨렸다.
module broken_accumulator(
  input  wire        clk,
  input  wire        reset,
  input  wire        enable,
  input  wire [15:0] addend,
  output reg  [15:0] total
);
  always @(posedge clk) begin
    if (reset) total <= 16'h0;
    else       total <= total + addend;    // enable 확인을 빠뜨렸다
  end
endmodule

module bad02_display_only;
  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  integer     step;

  broken_accumulator dut(.clk(clk), .reset(reset), .enable(enable),
                         .addend(addend), .total(total));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    @(posedge clk); #1;
    reset = 1'b0;

    $display("--- 출력만 남기는 방식 ---");
    for (step = 1; step <= 4; step = step + 1) begin
      enable = (step % 2 == 1);          // 홀수 단계에서만 켠다
      addend = 16'h0010;
      @(posedge clk); #1;
      $display("step %0d enable=%b total=%h", step, enable, total);
    end
    $display("숫자가 그럴듯해 보이므로 사람이 표를 검토해야 결함을 찾는다");
    $display("기대값은 10, 10, 20, 20 이고 실제는 10, 20, 30, 40 이다");
    $finish(0);
  end
endmodule
