// 예제 1-1. 시뮬레이터가 실행하는 가장 작은 Verilog 파일
// 포트가 없는 module 하나와 initial block 하나로 이루어진다.
`timescale 1ns/1ps

module ex01_hello;

  // initial block은 시뮬레이션 시각 0에서 한 번 실행된다.
  initial begin
    $display("hello from verilog");
    $display("simulation time = %0t", $time);
    $finish(0);
  end

endmodule
