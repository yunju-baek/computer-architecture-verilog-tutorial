// 의도적 함정 1. 순서 기반 연결에서 두 인자의 순서를 뒤집는다.
// 컴파일이 통과하고 값만 어긋난다.
`timescale 1ns/1ps

module subtractor(
  input  wire [7:0] minuend,      // 첫 번째 포트
  input  wire [7:0] subtrahend,   // 두 번째 포트
  output wire [7:0] difference
);
  assign difference = minuend - subtrahend;
endmodule

module bad01_positional;
  reg  [7:0] big_value, small_value;
  wire [7:0] correct_order, swapped_order;

  // 선언 순서대로 적었다.
  subtractor u_correct(big_value, small_value, correct_order);

  // 두 입력의 순서를 뒤집었다. 두 포트가 같은 폭이라 컴파일러가 통과시킨다.
  subtractor u_swapped(small_value, big_value, swapped_order);

  initial begin
    big_value = 8'd100; small_value = 8'd30;
    #1;
    $display("100 - 30 을 의도했다");
    $display("올바른 순서 -> %0d", correct_order);
    $display("뒤집힌 순서 -> %0d  30 - 100 이 계산되었다", swapped_order);
    $display("이름 기반 연결은 이 종류의 실수를 컴파일 단계에서 드러낸다");
    $finish(0);
  end
endmodule
