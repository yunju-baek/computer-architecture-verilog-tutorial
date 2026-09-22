// 점검 2-3. CH08 testbench. 누적기에 값 2개를 연속으로 더한 결과를 예상하고,
// 경계값 testbench 확장에 넣을 값 2개를 파생한다.
// 대상: tutorial/ch08/ex01_dut.v
//
// 입력은 하강 에지에 바꾸고, 상승 에지 뒤 #1에서 값을 읽는다. 두 덧셈 사이에 reset 은 0이다.
`timescale 1ns/1ps

module probe_ch08;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3, s4;
  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;
  reg  [15:0] x1, x2;
  reg  [15:0] total1, total2;
  reg         zero2, carry2;

  // tb_boundary.v 에 추가할 값 2개
  reg  [15:0] b10, b11;
  reg  [15:0] existing [0:9];
  integer     j, dup, fh;

  integer     fails;

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk); #1;
    end
  endtask

  // 원본 tb_ex03.v 의 경계값 10개와 겹치는 값은 1을 더해 피한다.
  task avoid_existing;
    inout [15:0] value;
    input [15:0] other;
    begin
      dup = 1;
      while (dup) begin
        dup = (value == other);
        for (j = 0; j < 10; j = j + 1)
          if (value == existing[j]) dup = 1;
        if (dup) value = value + 16'd1;
      end
    end
  endtask

  initial begin
    fails = 0;
    read_student_id(sid);

    existing[0] = 16'h0000; existing[1] = 16'h0001; existing[2] = 16'h7fff;
    existing[3] = 16'h8000; existing[4] = 16'hffff; existing[5] = 16'hfffe;
    existing[6] = 16'h00ff; existing[7] = 16'hff00; existing[8] = 16'h5555;
    existing[9] = 16'haaaa;

    // 입력 파생: salt 0x5A5A0800
    s1 = lcg_next(sid ^ 32'h5A5A0800);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    s4 = lcg_next(s3);
    x1  = {1'b1, s1[30:16]};             // 최상위 비트를 1로 두어 자리올림이 생길 여지를 만든다
    x2  = s2[31:16];
    b10 = s3[31:16];
    b11 = s4[31:16];
    avoid_existing(b10, 16'hffff);       // 기존 10개와 겹치지 않게 한다 (0xffff 는 이미 목록에 있어 other 로 무해하다)
    avoid_existing(b11, b10);            // b10 과도 겹치지 않게 한다

    $display("=== probe_ch08 STUDENT_ID=%0d ===", sid);
    $display("INPUT accumulator: reset 1에지 뒤 enable=1 로 addend x1=%h, 다음 에지에 x2=%h", x1, x2);
    $display("      TOTAL1 은 x1 을 더한 에지 뒤의 total, TOTAL2/ZERO2/CARRY2 는 x2 를 더한 에지 뒤의 값");
    $display("REQUIRED tb_boundary.v: boundary_values[10] = 16'h%h  boundary_values[11] = 16'h%h", b10, b11);

    // boundary-test 가 읽을 파일. build/ 는 Makefile 이 만든다.
    fh = $fopen("build/required_values.txt", "w");
    if (fh != 0) begin
      $fwrite(fh, "%h\n%h\n", b10, b11);
      $fclose(fh);
    end

    @(negedge clk);
    reset = 1'b1; enable = 1'b0; addend = 16'h0;
    step;                                 // 리셋 에지
    @(negedge clk);
    reset = 1'b0; enable = 1'b1; addend = x1;
    step;                                 // x1 덧셈
    total1 = total;
    @(negedge clk);
    addend = x2;
    step;                                 // x2 덧셈
    total2 = total; zero2 = zero; carry2 = carry;
    @(negedge clk);
    enable = 1'b0;

    `CHECK("CH08_TOTAL1", `P_CH08_TOTAL1, total1)
    `CHECK("CH08_TOTAL2", `P_CH08_TOTAL2, total2)
    `CHECK("CH08_ZERO2",  `P_CH08_ZERO2,  zero2)
    `CHECK("CH08_CARRY2", `P_CH08_CARRY2, carry2)
    `FINISH_CHECK("ch08", sid)
  end
endmodule
