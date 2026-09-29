// 예제 5-4. 동기 리셋과 비동기 리셋
`timescale 1ns/1ps

// 동기 리셋. clock 에지에서 reset을 확인한다.
module sync_reset_counter(
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  always @(posedge clk) begin
    if (reset)
      count <= 4'd0;
    else
      count <= count + 4'd1;
  end
endmodule

// 비동기 리셋. reset 에지에서도 블록이 실행된다.
module async_reset_counter(
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  always @(posedge clk or posedge reset) begin
    if (reset)
      count <= 4'd0;
    else
      count <= count + 4'd1;
  end
endmodule
