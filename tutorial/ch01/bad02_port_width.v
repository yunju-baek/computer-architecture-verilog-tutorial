// 의도적 경고 2. 포트 폭이 서로 다른 module을 연결한다.
// -Wall이 폭 불일치를 알려 주는 것을 확인하는 예제다.
`timescale 1ns/1ps

module narrow(
  input  wire [3:0] a,
  output wire [3:0] y
);
  assign y = ~a;
endmodule

module bad02_port_width;
  reg  [7:0] wide_in;    // 8비트
  wire [7:0] wide_out;   // 8비트

  // 4비트 포트에 8비트 신호를 연결하므로 상위 4비트가 사라진다.
  narrow u_narrow(.a(wide_in), .y(wide_out));

  initial begin
    wide_in = 8'hab;
    #1;
    $display("wide_in=%h wide_out=%h", wide_in, wide_out);
    $finish(0);
  end
endmodule
