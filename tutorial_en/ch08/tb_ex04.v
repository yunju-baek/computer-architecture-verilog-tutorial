// 예제 8-4. 무작위 입력과 참조 모델 대조.
// 경계값이 잡지 못하는 조합을 넓게 훑는다.
`timescale 1ns/1ps

module tb_ex04;

  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  // 참조 모델. DUT와 별개로 같은 계산을 한다.
  reg  [16:0] reference_wide;      // 자리올림을 담기 위해 한 비트 넓게 둔다
  reg  [15:0] reference_total;
  reg         reference_carry;

  integer     seed = 32'd20260825;  // seed를 고정해 실행마다 같은 나열을 얻는다
  integer     trial;

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    @(posedge clk); #1;
    reset = 1'b0;

    reference_total = 16'h0;
    reference_carry = 1'b0;

    $display("--- 무작위 입력 200회를 참조 모델과 대조한다 ---");
    for (trial = 0; trial < 200; trial = trial + 1) begin
      enable = 1'b1;
      addend = $random(seed);         // seed를 넘기면 나열이 재현된다

      // 참조 모델을 먼저 갱신한다.
      reference_wide  = {1'b0, reference_total} + {1'b0, addend};
      reference_total = reference_wide[15:0];
      reference_carry = reference_wide[16];

      @(posedge clk); #1;
      enable = 1'b0;

      if (total !== reference_total)
        $fatal(1, "FAIL trial=%0d addend=%h total=%h expected=%h",
               trial, addend, total, reference_total);
      if (carry !== reference_carry)
        $fatal(1, "FAIL trial=%0d carry=%b expected=%b",
               trial, carry, reference_carry);
      if (zero !== (reference_total == 16'h0))
        $fatal(1, "FAIL trial=%0d zero=%b total=%h", trial, zero, reference_total);

      if (trial < 5)
        $display("trial %0d: addend=%h total=%h carry=%b", trial, addend, total, carry);
    end

    $display("seed %0d으로 200회를 확인했다", 32'd20260825);
    $display("PASS ch08 ex04 무작위 200회");
    $finish(0);
  end

endmodule
