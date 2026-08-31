// 의도적 오류 2. 선언을 생략한 이름을 사용한다.
// Verilog는 미선언 식별자를 1비트 wire로 자동 생성하므로
// 오타가 컴파일을 통과하고 상위 비트가 사라진다.
`timescale 1ns/1ps

module inverter_typo(
  input  wire [3:0] a,
  output wire [3:0] y
);
  // 의도한 것은 4비트 중간 신호인데 선언을 빠뜨렸다.
  assign inverted = ~a;    // inverted가 1비트 wire로 자동 생성된다
  assign y        = inverted;
endmodule

module bad02_implicit_wire;
  reg  [3:0] a;
  wire [3:0] y;

  inverter_typo dut(.a(a), .y(y));

  initial begin
    a = 4'b0011;
    #1;
    $display("a = %b", a);
    $display("y = %b   의도한 값은 1100이다", y);
    $finish(0);
  end
endmodule
