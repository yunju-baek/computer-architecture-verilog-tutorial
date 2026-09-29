// 예제 2-6. parameter로 폭을 정하면 같은 코드를 여러 폭에 쓸 수 있다.
`timescale 1ns/1ps

module ex06_adder #(
  parameter WIDTH = 8            // instance마다 다른 값을 줄 수 있다
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  output wire [WIDTH-1:0] sum,
  output wire             carry
);

  // localparam은 모듈 안에서만 값을 정하는 상수다.
  localparam RESULT_WIDTH = WIDTH + 1;

  wire [RESULT_WIDTH-1:0] wide_sum;

  assign wide_sum = a + b;
  assign sum      = wide_sum[WIDTH-1:0];
  assign carry    = wide_sum[WIDTH];

endmodule
