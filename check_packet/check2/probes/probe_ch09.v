// 점검 2-4. CH09 합성 가능한 RTL. 연산 3개를 순서대로 적용한 결과 레지스터를 예상한다.
// 대상: tutorial/ch09/ex01_synthesizable.v (WIDTH=8)
//
// operation 코드: 0=ADD 1=SUB 2=AND 3=OR. reset 뒤 result 는 0에서 시작한다.
// 입력은 하강 에지에 바꾸고, 상승 에지 뒤 #1에서 값을 읽는다.
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

    // 입력 파생: salt 0x5A5A0900. 단계마다 상위 2비트가 연산, 다음 8비트가 피연산자다.
    s1 = lcg_next(sid ^ 32'h5A5A0900);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    op[0] = s1[31:30]; val[0] = s1[29:22];
    op[1] = s2[31:30]; val[1] = s2[29:22];
    op[2] = s3[31:30]; val[2] = s3[29:22];

    $display("=== probe_ch09 STUDENT_ID=%0d ===", sid);
    $display("INPUT reset 1에지 뒤 enable=1 로 다음 3단계를 차례로 적용한다 (result 시작값 00)");
    for (i = 0; i < 3; i = i + 1) begin
      name = op_name(op[i]);
      $display("      단계%0d: operation=%b (%s)  operand=%h", i + 1, op[i], name, val[i]);
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
