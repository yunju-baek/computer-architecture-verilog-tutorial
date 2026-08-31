// 예제 1-4. $display 서식 문자. 디버깅 출력의 기본 도구다.
`timescale 1ns/1ps

module ex04_display;

  reg [7:0]  byte_value;
  reg [31:0] word_value;

  initial begin
    byte_value = 8'b1010_0011;
    word_value = 32'hdead_beef;

    $display("binary       %%b   = %b", byte_value);
    $display("hex          %%h   = %h", byte_value);
    $display("decimal      %%d   = %d", byte_value);
    $display("decimal trim %%0d  = %0d", byte_value);
    $display("octal        %%o   = %o", byte_value);
    $display("signed       %%0d  = %0d", $signed(byte_value));
    $display("32bit hex    %%h   = %h", word_value);
    $display("width 8      %%8b  = %8b", byte_value[3:0]);
    $display("string       %%s   = %s", "opcode");
    $display("time         %%0t  = %0t", $time);
    $finish(0);
  end

endmodule
