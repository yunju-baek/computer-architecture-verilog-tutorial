// 예제 10-3. always_comb 가 always @* 보다 더 보장하는 것.
// always_comb 는 시뮬레이션 시각 0에서 한 번 실행된다.
// always @* 는 감지 목록의 신호가 바뀔 때 실행되므로, 선언 초기화만 있고
// 그 뒤 입력이 같은 값에 머무르면 블록이 대기 상태로 남는다.
`timescale 1ns/1ps

module comb_systemverilog(
  input  logic [3:0] a,
  input  logic [3:0] b,
  output logic [3:0] y
);
  always_comb begin
    y = a + b;
  end
endmodule

module comb_verilog2001(
  input  wire [3:0] a,
  input  wire [3:0] b,
  output reg  [3:0] y
);
  always @* begin
    y = a + b;
  end
endmodule

module ex03_always_comb;

  // 선언에서 초기화한다. 이 대입은 시각 0에 일어난다.
  logic [3:0] a = 4'd3;
  logic [3:0] b = 4'd4;
  logic [3:0] y_sv, y_v;

  comb_systemverilog u_sv(.a(a), .b(b), .y(y_sv));
  comb_verilog2001   u_v (.a(a), .b(b), .y(y_v));

  initial begin
    $timeformat(-9, 0, "ns", 6);

    #0;
    $display("%t always_comb=%b  always @*=%b", $time, y_sv, y_v);

    #1;
    $display("%t always_comb=%b  always @*=%b", $time, y_sv, y_v);
    $display("입력이 시각 0 이후로 변하지 않으면 always @* 블록은 대기 상태에 머문다");

    if (y_sv !== 4'd7) $fatal(1, "FAIL always_comb 결과 y_sv=%b", y_sv);

    // 입력을 한 번 바꾸면 always @* 블록도 실행된다.
    a = 4'd5;
    #1;
    $display("%t 입력을 바꾼 뒤 always_comb=%b  always @*=%b", $time, y_sv, y_v);
    if (y_sv !== 4'd9) $fatal(1, "FAIL y_sv=%b", y_sv);
    if (y_v  !== 4'd9) $fatal(1, "FAIL y_v=%b", y_v);
    $display("입력이 한 번 바뀐 뒤에는 두 표기가 같은 값을 낸다");

    $display("PASS ch10 ex03 always_comb");
    $finish(0);
  end

endmodule
