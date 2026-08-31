// 예제 3-4의 testbench.
`timescale 1ns/1ps

module tb_ex04;

  reg  [31:0] value;
  reg  [4:0]  amount;
  wire [31:0] sll_result, srl_result, sra_result;

  // >>> 를 부호 없는 값에 쓰면 어떻게 되는지 함께 확인한다
  wire [31:0] sra_without_signed;

  ex04_shift dut(
    .value(value), .amount(amount),
    .sll_result(sll_result), .srl_result(srl_result), .sra_result(sra_result)
  );

  assign sra_without_signed = value >>> amount;

  initial begin
    $display("--- 양수를 시프트한다 ---");
    value = 32'h0000_00f0; amount = 5'd4;
    #1;
    $display("value = %h, amount = %0d", value, amount);
    $display("sll = %h  (<< 4)", sll_result);
    $display("srl = %h  (>> 4)", srl_result);
    $display("sra = %h  (>>> 4)", sra_result);
    if (sll_result !== 32'h0000_0f00) $fatal(1, "FAIL sll=%h", sll_result);
    if (srl_result !== 32'h0000_000f) $fatal(1, "FAIL srl=%h", srl_result);
    if (sra_result !== 32'h0000_000f) $fatal(1, "FAIL sra=%h", sra_result);

    $display("--- 음수를 시프트한다. srl과 sra가 갈라진다 ---");
    value = 32'hffff_fff0;   // 부호 있게 읽으면 -16
    amount = 5'd4;
    #1;
    $display("value = %h (%0d)", value, $signed(value));
    $display("srl = %h (%0d)  상위를 0으로 채운다", srl_result, $signed(srl_result));
    $display("sra = %h (%0d)  상위를 부호 비트로 채운다", sra_result, $signed(sra_result));
    if (srl_result !== 32'h0fff_ffff) $fatal(1, "FAIL srl=%h", srl_result);
    if (sra_result !== 32'hffff_ffff) $fatal(1, "FAIL sra=%h", sra_result);

    $display("--- $signed 없이 >>> 를 쓰면 srl과 같아진다 ---");
    $display("$signed(value) >>> 4 = %h", sra_result);
    $display("value >>> 4          = %h", sra_without_signed);
    if (sra_without_signed !== 32'h0fff_ffff) $fatal(1, "FAIL 부호 없는 >>>");

    $display("--- shift amount는 하위 5비트만 쓴다 ---");
    value = 32'h0000_0001; amount = 5'd31;
    #1;
    $display("1 << 31 = %h", sll_result);
    if (sll_result !== 32'h8000_0000) $fatal(1, "FAIL sll=%h", sll_result);

    value = 32'h8000_0000; amount = 5'd0;
    #1;
    $display("amount가 0이면 값이 그대로 남는다: %h", sll_result);
    if (sll_result !== 32'h8000_0000) $fatal(1, "FAIL sll=%h", sll_result);

    $display("PASS ch03 ex04 shift");
    $finish(0);
  end

endmodule
