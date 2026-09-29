// 의도적 함정 2. case에 default를 빠뜨린다.
// 열거를 생략한 입력에서 출력이 이전 값을 유지한다.
`timescale 1ns/1ps

module partial_decoder(
  input  wire [1:0] mode,
  output reg  [3:0] result
);
  always @* begin
    case (mode)
      2'b00: result = 4'h1;
      2'b01: result = 4'h2;
      2'b10: result = 4'h4;
      // 2'b11 경로와 default가 함께 빠져 있다.
    endcase
  end
endmodule

module bad02_incomplete_case;
  reg  [1:0] mode;
  wire [3:0] result;
  integer    i;

  partial_decoder dut(.mode(mode), .result(result));

  initial begin
    $display("mode | result");
    $display("-----+-------");
    for (i = 0; i < 4; i = i + 1) begin
      mode = i[1:0];
      #1;
      $display("  %b  |   %h", mode, result);
    end
    $display("mode=11에서 이전 값 4가 남는다");
    $finish(0);
  end
endmodule
