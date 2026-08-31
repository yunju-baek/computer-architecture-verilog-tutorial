// 예제 8-1. testbench의 표준 골격.
// clock 생성, 리셋 절차, 검사 task, 종료 규약을 갖춘다.
`timescale 1ns/1ps

module tb_ex01;

  // 1. 신호 선언. DUT 입력은 reg, DUT 출력은 wire다.
  reg         clk = 1'b0;
  reg         reset;
  reg         enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  // 2. 상수를 한곳에 모은다.
  localparam CLOCK_HALF = 5;         // 반주기 5ns이므로 주기는 10ns

  // 3. DUT instance
  ex01_dut dut(
    .clk(clk), .reset(reset), .enable(enable), .addend(addend),
    .total(total), .zero(zero), .carry(carry)
  );

  // 4. clock 생성
  always #CLOCK_HALF clk = ~clk;

  // 5. 재사용할 절차를 task로 정리한다.
  task apply_reset;
    begin
      reset  = 1'b1;
      enable = 1'b0;
      addend = 16'h0000;
      @(posedge clk);
      #1;
      reset = 1'b0;
    end
  endtask

  task add_value;
    input [15:0] value;
    begin
      enable = 1'b1;
      addend = value;
      @(posedge clk);
      #1;
      enable = 1'b0;
    end
  endtask

  task check_total;
    input [15:0] expected;
    input [8*32-1:0] label;         // 실패 메시지에 담을 이름
    begin
      if (total !== expected)
        $fatal(1, "FAIL %0s total=%h expected=%h", label, total, expected);
    end
  endtask

  // 6. 시나리오
  initial begin
    $timeformat(-9, 0, "ns", 6);

    apply_reset;
    check_total(16'h0000, "리셋 직후");
    if (zero !== 1'b1) $fatal(1, "FAIL 리셋 직후 zero=%b", zero);

    add_value(16'h0010);
    check_total(16'h0010, "10 더한 뒤");

    add_value(16'h0020);
    check_total(16'h0030, "20 더한 뒤");

    // enable을 끈 사이클에서 값이 유지되는지 확인한다.
    enable = 1'b0; addend = 16'h00ff;
    @(posedge clk); #1;
    check_total(16'h0030, "enable을 끈 사이클");

    $display("PASS ch08 ex01 골격");
    $finish(0);
  end

  // 7. 안전장치. 시나리오가 끝나지 않으면 강제로 중단한다.
  initial begin
    #10000;
    $fatal(1, "FAIL 제한 시각을 넘겼다");
  end

endmodule
