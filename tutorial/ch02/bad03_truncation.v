// 의도적 경고 3. 폭보다 큰 값을 대입한다.
`timescale 1ns/1ps

module bad03_truncation;

  reg [7:0] narrow;
  reg [3:0] tiny;

  initial begin
    narrow = 8'h1ff;      // 9비트 값을 8비트에 넣는다
    $display("8'h1ff -> %h", narrow);

    tiny = 4'hf + 4'h1;   // 4비트 연산 결과를 4비트에 넣으므로 carry가 사라진다
    $display("4'hf + 4'h1 -> %h", tiny);

    tiny = 300;           // 10진 300을 4비트에 넣는다
    $display("300 -> %h", tiny);

    $finish(0);
  end

endmodule
