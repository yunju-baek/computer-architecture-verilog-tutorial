// 예제 3-5. 덧셈 결과에서 플래그 4개를 얻는다.
// 폭은 4비트로 두어 원리를 확인한다. 32비트 확장은 HW02에서 다룬다.
`timescale 1ns/1ps

module ex05_flags(
  input  wire [3:0] a,
  input  wire [3:0] b,
  output wire [3:0] sum,
  output wire       zero,      // 결과의 모든 비트가 0인가
  output wire       negative,  // 부호 있는 해석에서 음수인가
  output wire       carry,     // 부호 없는 해석에서 자리올림이 났는가
  output wire       overflow   // 부호 있는 해석에서 표현 범위를 넘었는가
);

  // 결과를 한 비트 넓게 계산하면 최상위 비트가 자리올림이 된다.
  wire [4:0] wide_sum = {1'b0, a} + {1'b0, b};

  assign sum      = wide_sum[3:0];
  assign carry    = wide_sum[4];

  // reduction NOR는 모든 비트가 0인지 판단한다.
  assign zero     = ~|sum;

  // 부호 있는 해석에서 최상위 비트가 부호다.
  assign negative = sum[3];

  // 부호 있는 넘침은 두 조건이 함께 성립할 때 일어난다.
  //   조건 1. 두 피연산자의 부호가 같다
  //   조건 2. 결과의 부호가 피연산자의 부호와 다르다
  assign overflow = (a[3] == b[3]) && (sum[3] != a[3]);

endmodule
