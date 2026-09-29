// 의도적 함정 2. 반복 횟수가 실행 중에 정해지는 반복문을 설계 코드에 넣는다.
`timescale 1ns/1ps

module bad02_while;

  // 반복 횟수가 상수인 for. 합성 단계에서 펼쳐진다.
  function [3:0] count_ones_fixed;
    input [7:0] value;
    integer index;
    begin
      count_ones_fixed = 4'd0;
      for (index = 0; index < 8; index = index + 1)
        count_ones_fixed = count_ones_fixed + {3'b0, value[index]};
    end
  endfunction

  // 반복 횟수가 입력에 따라 달라지는 while. 게이트로 펼치려면 고정 횟수가 필요하다.
  function [3:0] count_shifts_until_zero;
    input [7:0] value;
    reg [7:0] working;
    begin
      count_shifts_until_zero = 4'd0;
      working = value;
      while (working != 8'd0) begin
        working = working >> 1;
        count_shifts_until_zero = count_shifts_until_zero + 4'd1;
      end
    end
  endfunction

  reg [7:0] sample;

  initial begin
    $display("value    | 1의 개수  0이 될 때까지의 시프트 수");
    $display("---------+-----------------------------------");
    sample = 8'b0000_0000; $display("%b |    %0d          %0d",
             sample, count_ones_fixed(sample), count_shifts_until_zero(sample));
    sample = 8'b0000_0001; $display("%b |    %0d          %0d",
             sample, count_ones_fixed(sample), count_shifts_until_zero(sample));
    sample = 8'b1000_0000; $display("%b |    %0d          %0d",
             sample, count_ones_fixed(sample), count_shifts_until_zero(sample));
    sample = 8'b1111_1111; $display("%b |    %0d          %0d",
             sample, count_ones_fixed(sample), count_shifts_until_zero(sample));

    $display("for는 반복 8회로 고정되어 게이트로 펼쳐진다");
    $display("while은 입력에 따라 반복이 0회에서 8회까지 달라진다");
    $finish(0);
  end
endmodule
