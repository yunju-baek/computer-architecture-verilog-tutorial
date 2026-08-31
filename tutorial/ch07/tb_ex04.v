// 예제 7-4의 testbench. 입력 나열을 넣고 검출 시점을 확인한다.
`timescale 1ns/1ps

module tb_ex04;

  reg  clk = 1'b0;
  reg  reset;
  reg  bit_in;
  wire detected;

  // 입력 나열과 기대 출력을 나란히 둔다.
  localparam PATTERN_LENGTH = 12;
  reg [PATTERN_LENGTH-1:0] input_pattern    = 12'b0110_1110_1111;
  reg [PATTERN_LENGTH-1:0] expected_pattern = 12'b0000_0001_0001;

  integer step;

  ex04_fsm dut(.clk(clk), .reset(reset), .bit_in(bit_in), .detected(detected));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1; bit_in = 1'b0;
    @(posedge clk); #1;
    reset = 1'b0;

    $display("step in state detected");
    $display("----------------------");

    // 최상위 비트부터 넣는다.
    for (step = PATTERN_LENGTH - 1; step >= 0; step = step - 1) begin
      bit_in = input_pattern[step];
      #1;
      $display(" %2d   %b    %0d      %b",
               PATTERN_LENGTH - 1 - step, bit_in, dut.state, detected);

      if (detected !== expected_pattern[step])
        $fatal(1, "FAIL step=%0d detected=%b expected=%b",
               PATTERN_LENGTH - 1 - step, detected, expected_pattern[step]);

      @(posedge clk);
    end

    $display("PASS ch07 ex04 fsm, 12 steps");
    $finish(0);
  end

endmodule
