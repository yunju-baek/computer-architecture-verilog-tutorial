// 예제 1-2의 testbench. 입력 16가지를 모두 넣고 기대값과 대조한다.
`timescale 1ns/1ps

module tb_ex02;

  reg  [3:0] a;     // DUT 입력을 구동하므로 reg로 선언한다
  wire [3:0] y;     // DUT 출력을 관찰하므로 wire로 선언한다
  integer    i;

  // DUT instance. 포트 이름을 명시해 연결한다.
  ex02_inverter dut(.a(a), .y(y));

  initial begin
    for (i = 0; i < 16; i = i + 1) begin
      a = i[3:0];
      #1;                                  // 값이 전파될 시간을 1ns 준다
      if (y !== ~a)
        $fatal(1, "FAIL a=%b y=%b expected=%b", a, y, ~a);
    end
    $display("PASS ch01 ex02 inverter, 16 vectors");
    $finish(0);
  end

endmodule
