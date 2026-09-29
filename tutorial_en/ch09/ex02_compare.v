// 예제 9-2. 같은 기능을 합성 대상 코드와 시뮬레이션 전용 코드로 각각 쓴다.
// 두 결과가 일치하므로 시뮬레이션 결과만으로 두 코드를 구별하기 어렵다.
`timescale 1ns/1ps

// 합성 가능한 형태. 상태 소자와 조합 논리로 이루어진다.
module counter_synthesizable(
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  always @(posedge clk) begin
    if (reset) count <= 4'd0;
    else       count <= count + 4'd1;
  end
endmodule

// 시뮬레이션 전용 형태. initial과 지연으로 같은 값을 만든다.
module counter_simulation_only(
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  // initial로 초기값을 준다. 합성 도구의 처리 범위를 벗어난다.
  initial count = 4'd0;

  always @(posedge clk) begin
    #1;                        // 지연문. 합성 단계에서 버려진다
    if (reset) count = 4'd0;
    else       count = count + 4'd1;
  end
endmodule
