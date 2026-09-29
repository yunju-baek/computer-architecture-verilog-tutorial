// 예제 5-2. 순차 블록에서 = 와 <= 는 다른 회로를 만든다.
// 같은 3단 시프트 레지스터를 두 대입으로 쓴다.
`timescale 1ns/1ps

// 논블로킹 대입. 세 레지스터가 같은 에지에서 이전 값을 기준으로 갱신된다.
module shift_nonblocking(
  input  wire clk,
  input  wire d,
  output reg  q0,
  output reg  q1,
  output reg  q2
);
  always @(posedge clk) begin
    q0 <= d;
    q1 <= q0;      // 이 에지 이전의 q0을 읽는다
    q2 <= q1;      // 이 에지 이전의 q1을 읽는다
  end
endmodule

// 블로킹 대입. 앞 문장의 결과가 뒤 문장에 즉시 보인다.
module shift_blocking(
  input  wire clk,
  input  wire d,
  output reg  q0,
  output reg  q1,
  output reg  q2
);
  always @(posedge clk) begin
    q0 = d;
    q1 = q0;       // 방금 대입한 q0을 읽는다
    q2 = q1;       // 방금 대입한 q1을 읽는다
  end
endmodule
