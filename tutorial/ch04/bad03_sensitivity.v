// 의도적 함정 3. 감지 목록을 직접 적고 신호를 빠뜨린다.
// always @* 는 이 실수를 막아 준다.
`timescale 1ns/1ps

module manual_sensitivity(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] sum_partial,   // a만 감지한다
  output reg  [7:0] sum_complete   // a와 b를 모두 감지한다
);
  // 이 블록은 a가 바뀔 때만 다시 계산된다.
  always @(a) begin
    sum_partial = a + b;
  end

  // always @* 는 우변의 모든 신호를 자동으로 감지한다.
  always @* begin
    sum_complete = a + b;
  end
endmodule

module bad03_sensitivity;
  reg  [7:0] a, b;
  wire [7:0] sum_partial, sum_complete;

  manual_sensitivity dut(.a(a), .b(b),
                         .sum_partial(sum_partial), .sum_complete(sum_complete));

  initial begin
    a = 8'h10; b = 8'h01; #1;
    $display("a=%h b=%h -> partial=%h complete=%h", a, b, sum_partial, sum_complete);

    b = 8'h02; #1;
    $display("b만 바꾼다     -> partial=%h complete=%h", sum_partial, sum_complete);
    $display("partial은 이전 결과를 유지하고 complete는 갱신된다");

    a = 8'h20; #1;
    $display("a를 바꾼다     -> partial=%h complete=%h", sum_partial, sum_complete);
    $display("a가 바뀌면 partial도 뒤늦게 갱신된다");

    $finish(0);
  end
endmodule
