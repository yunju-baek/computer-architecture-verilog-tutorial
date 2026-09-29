// 의도적 함정 1. 설계 코드에 지연문을 넣는다.
// 시뮬레이션은 그 지연을 지키고 합성 도구는 그 값을 버린다.
`timescale 1ns/1ps

module delayed_logic(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] slow_sum,
  output wire [7:0] fast_sum
);
  // 지연문을 넣은 조합 논리
  always @* begin
    #3 slow_sum = a + b;
  end

  // 지연 없는 조합 논리
  assign fast_sum = a + b;
endmodule

module bad01_delay;
  reg  [7:0] a, b;
  wire [7:0] slow_sum, fast_sum;

  delayed_logic dut(.a(a), .b(b), .slow_sum(slow_sum), .fast_sum(fast_sum));

  initial begin
    $timeformat(-9, 0, "ns", 6);

    a = 8'h10; b = 8'h20;
    #1;
    $display("%t 입력을 준 1ns 뒤  slow=%h fast=%h", $time, slow_sum, fast_sum);
    #5;
    $display("%t 6ns 뒤           slow=%h fast=%h", $time, slow_sum, fast_sum);

    a = 8'h30;
    #1;
    $display("%t 입력을 바꾼 1ns 뒤 slow=%h fast=%h", $time, slow_sum, fast_sum);
    #5;
    $display("%t 6ns 뒤           slow=%h fast=%h", $time, slow_sum, fast_sum);

    $display("합성 도구는 지연값을 버리므로 실제 회로에서 두 출력이 함께 바뀐다");
    $finish(0);
  end
endmodule
