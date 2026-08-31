// 예제 6-4의 testbench. 두 구현이 모든 입력에서 일치하는지 확인한다.
`timescale 1ns/1ps

module tb_ex04;

  reg  [7:0] value;
  reg  [2:0] amount;
  wire [7:0] barrel_result, staged_result;
  integer    i, j;

  ex04_shifter #(.USE_BARREL(1)) u_barrel(.value(value), .amount(amount),
                                          .result(barrel_result));
  ex04_shifter #(.USE_BARREL(0)) u_staged(.value(value), .amount(amount),
                                          .result(staged_result));

  initial begin
    $display("value    amount | barrel   staged");
    $display("----------------+----------------");
    for (i = 0; i < 256; i = i + 1) begin
      for (j = 0; j < 8; j = j + 1) begin
        value  = i[7:0];
        amount = j[2:0];
        #1;
        if (i == 8'h81 && j < 4)
          $display("%b %0d      | %b %b", value, amount, barrel_result, staged_result);

        if (barrel_result !== staged_result)
          $fatal(1, "FAIL value=%b amount=%0d barrel=%b staged=%b",
                 value, amount, barrel_result, staged_result);
        if (barrel_result !== (value << amount))
          $fatal(1, "FAIL 기대값 value=%b amount=%0d result=%b", value, amount, barrel_result);
      end
    end
    $display("PASS ch06 ex04 generate if, 2048 vectors");
    $finish(0);
  end

endmodule
