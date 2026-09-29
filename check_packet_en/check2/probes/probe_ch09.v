// Check 2-4. CH09 Synthesizable RTL. Predict result register after applying 3 consecutive operations.
// Target: tutorial/ch09/ex01_synthesizable.v (WIDTH=8)
//
// Operation codes: 0=ADD 1=SUB 2=AND 3=OR. Following reset, result initializes to 0.
// Inputs update on clock falling edge; states sample at #1 after clock rising edge.
`timescale 1ns/1ps

module probe_ch09;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3;
  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [1:0]  operation;
  reg  [7:0]  operand;
  wire [7:0]  result;
  wire        is_zero;
  reg  [1:0]  op [0:2];
  reg  [7:0]  val [0:2];
  reg  [8*3-1:0] name;
  integer     i;
  integer     fails;

  ex01_synthesizable #(.WIDTH(8)) dut(.clk(clk), .reset(reset), .enable(enable),
                                      .operation(operation), .operand(operand),
                                      .result(result), .is_zero(is_zero));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk); #1;
    end
  endtask

  function [8*3-1:0] op_name;
    input [1:0] code;
    begin
      case (code)
        2'd0: op_name = "ADD";
        2'd1: op_name = "SUB";
        2'd2: op_name = "AND";
        default: op_name = "OR ";
      endcase
    end
  endfunction

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0900. High 2 bits select opcode; following 8 bits provide operand.
    s1 = lcg_next(sid ^ 32'h5A5A0900);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    op[0] = s1[31:30]; val[0] = s1[29:22];
    op[1] = s2[31:30]; val[1] = s2[29:22];
    op[2] = s3[31:30]; val[2] = s3[29:22];

    $display("=== probe_ch09 STUDENT_ID=%0d ===", sid);
    $display("INPUT Following 1 reset edge, assert enable=1 and apply 3 operations sequentially (initial result=00)");
    for (i = 0; i < 3; i = i + 1) begin
      name = op_name(op[i]);
      $display("      Stage %0d: operation=%b (%s)  operand=%h", i + 1, op[i], name, val[i]);
    end

    @(negedge clk);
    reset = 1'b1; enable = 1'b0; operation = 2'd0; operand = 8'h00;
    step;
    @(negedge clk);
    reset = 1'b0; enable = 1'b1;
    for (i = 0; i < 3; i = i + 1) begin
      operation = op[i]; operand = val[i];
      step;
      @(negedge clk);
    end
    enable = 1'b0;

    `CHECK("CH09_RESULT",  `P_CH09_RESULT,  result)
    `CHECK("CH09_IS_ZERO", `P_CH09_IS_ZERO, is_zero)
    `FINISH_CHECK("ch09", sid)
  end
endmodule
