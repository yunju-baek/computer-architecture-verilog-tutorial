// 예제 8-2. 실패를 처리하는 두 방식.
// 즉시 중단은 첫 결함에 멈추고, 누적 집계는 전체를 훑은 뒤 요약한다.
`timescale 1ns/1ps

module tb_ex02;

  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  integer     error_count = 0;
  integer     check_count = 0;
  integer     i;
  reg  [15:0] reference;      // 참조 모델. testbench가 따로 계산한다

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  // 방식 1. 즉시 중단. 첫 결함에서 멈춘다.
  task check_now;
    input [15:0] expected;
    input [8*32-1:0] label;
    begin
      check_count = check_count + 1;
      if (total !== expected)
        $fatal(1, "FAIL %0s total=%h expected=%h", label, total, expected);
    end
  endtask

  // 방식 2. 누적 집계. 결함을 기록하고 계속 진행한다.
  task check_and_count;
    input [15:0] expected;
    input [8*32-1:0] label;
    begin
      check_count = check_count + 1;
      if (total !== expected) begin
        error_count = error_count + 1;
        $display("  결함 %0d: %0s total=%h expected=%h",
                 error_count, label, total, expected);
      end
    end
  endtask

  initial begin
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    @(posedge clk); #1;
    reset = 1'b0;
    reference = 16'h0;

    $display("--- 누적 집계 방식으로 32회를 훑는다 ---");
    for (i = 1; i <= 32; i = i + 1) begin
      enable = 1'b1;
      addend = i[15:0] * 16'd37;         // 값이 겹치지 않게 흩는다
      reference = reference + addend;
      @(posedge clk); #1;
      enable = 1'b0;
      check_and_count(reference, "누적 덧셈");
    end

    $display("--- 즉시 중단 방식으로 경계값을 확인한다 ---");
    reset = 1'b1; @(posedge clk); #1; reset = 1'b0;
    check_now(16'h0000, "리셋");

    enable = 1'b1; addend = 16'hffff; @(posedge clk); #1; enable = 1'b0;
    check_now(16'hffff, "최대값 한 번");

    enable = 1'b1; addend = 16'h0001; @(posedge clk); #1; enable = 1'b0;
    check_now(16'h0000, "폭 순환");
    if (carry !== 1'b1) $fatal(1, "FAIL 순환 시 carry=%b", carry);
    if (zero  !== 1'b1) $fatal(1, "FAIL 순환 시 zero=%b", zero);

    // 요약을 남긴다. 검사 수와 결함 수를 함께 적는다.
    $display("검사 %0d회, 결함 %0d건", check_count, error_count);
    if (error_count != 0)
      $fatal(1, "FAIL 결함 %0d건", error_count);

    $display("PASS ch08 ex02 실패 처리");
    $finish(0);
  end

endmodule
