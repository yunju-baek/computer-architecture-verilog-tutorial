// 예제 6-2의 testbench.
`timescale 1ns/1ps

module tb_ex02;

  reg  [7:0] value_a, value_b;
  wire [7:0] nq, nr, oq, orem;

  ex02_connection dut(
    .value_a(value_a), .value_b(value_b),
    .named_quotient(nq), .named_remainder(nr),
    .ordered_quotient(oq), .ordered_remainder(orem)
  );

  initial begin
    value_a = 8'd100; value_b = 8'd7;
    #1;
    $display("100 / 7  -> 이름 기반 q=%0d r=%0d", nq, nr);
    $display("100 / 7  -> 순서 기반 q=%0d r=%0d", oq, orem);
    if (nq !== oq || nr !== orem) $fatal(1, "FAIL 두 연결 방식의 결과가 다르다");
    if (nq !== 8'd14 || nr !== 8'd2) $fatal(1, "FAIL q=%0d r=%0d", nq, nr);

    value_a = 8'd50; value_b = 8'd0;
    #1;
    $display("50 / 0   -> q=%0d r=%0d  0으로 나누는 경우를 스텁이 처리한다", nq, nr);

    $display("PASS ch06 ex02 connection");
    $finish(0);
  end

endmodule
