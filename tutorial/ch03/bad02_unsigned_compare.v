// 의도적 함정 2. 부호 없는 비교로 음수를 판정하려 한다.
// RV32I의 slt와 sltu가 다른 명령어인 이유가 여기에 있다.
`timescale 1ns/1ps

module bad02_unsigned_compare;

  reg [31:0] x, y;

  initial begin
    x = 32'hffff_ffff;   // 부호 있게 -1, 부호 없이 4294967295
    y = 32'h0000_0001;   // 1

    $display("x = %h, y = %h", x, y);
    $display("부호 있는 해석: x = %0d, y = %0d", $signed(x), $signed(y));

    $display("--- 선언이 부호 없으므로 비교도 부호 없이 이루어진다 ---");
    $display("x < y                   = %b  sltu의 결과다", x < y);
    $display("$signed(x) < $signed(y) = %b  slt의 결과다", $signed(x) < $signed(y));

    $display("--- $signed는 양쪽에 붙여야 작용한다 ---");
    $display("$signed(x) < y          = %b  y가 부호 없으므로 전체가 부호 없이 계산된다",
             $signed(x) < y);

    $display("--- 음수 판정은 최상위 비트로 한다 ---");
    $display("x[31] = %b  이 방법은 선언과 무관하게 동작한다", x[31]);

    $finish(0);
  end

endmodule
