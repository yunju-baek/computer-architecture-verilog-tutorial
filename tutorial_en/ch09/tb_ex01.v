// 예제 9-1의 testbench.
`timescale 1ns/1ps

module tb_ex01;

  reg        clk = 1'b0;
  reg        reset, enable;
  reg  [1:0] operation;
  reg  [7:0] operand;
  wire [7:0] result;
  wire       is_zero;

  ex01_synthesizable #(.WIDTH(8)) dut(
    .clk(clk), .reset(reset), .enable(enable),
    .operation(operation), .operand(operand),
    .result(result), .is_zero(is_zero)
  );

  always #5 clk = ~clk;

  task run_op;
    input [1:0]      op;
    input [7:0]      value;
    input [7:0]      expected;
    input [8*24-1:0] label;
    begin
      operation = op;
      operand   = value;
      enable    = 1'b1;
      @(posedge clk); #1;
      enable = 1'b0;
      if (result !== expected)
        $fatal(1, "FAIL %0s result=%h expected=%h", label, result, expected);
      $display("%0s -> result=%h is_zero=%b", label, result, is_zero);
    end
  endtask

  initial begin
    reset = 1'b1; enable = 1'b0; operation = 2'd0; operand = 8'h0;
    @(posedge clk); #1;
    reset = 1'b0;

    if (result !== 8'h00) $fatal(1, "FAIL 리셋 result=%h", result);
    if (is_zero !== 1'b1) $fatal(1, "FAIL 리셋 is_zero=%b", is_zero);

    run_op(2'd0, 8'h30, 8'h30, "add 30");
    run_op(2'd0, 8'h05, 8'h35, "add 05");
    run_op(2'd1, 8'h05, 8'h30, "sub 05");
    run_op(2'd2, 8'h0f, 8'h00, "and 0f");
    if (is_zero !== 1'b1) $fatal(1, "FAIL and 뒤 is_zero=%b", is_zero);
    run_op(2'd3, 8'hab, 8'hab, "or ab");

    $display("PASS ch09 ex01 합성 가능 구조");
    $finish(0);
  end

endmodule
