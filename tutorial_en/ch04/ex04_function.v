// 예제 4-4. function으로 조합 논리를 이름 붙여 재사용한다.
`timescale 1ns/1ps

module ex04_function(
  input  wire [31:0] a,
  input  wire [31:0] b,
  output wire [31:0] max_unsigned,
  output wire [31:0] max_signed,
  output wire [4:0]  leading_zeros
);

  // function은 입력을 받아 값 하나를 돌려준다. 조합 논리로 합성된다.
  function [31:0] pick_larger_unsigned;
    input [31:0] left;
    input [31:0] right;
    begin
      pick_larger_unsigned = (left > right) ? left : right;
    end
  endfunction

  function [31:0] pick_larger_signed;
    input [31:0] left;
    input [31:0] right;
    begin
      pick_larger_signed = ($signed(left) > $signed(right)) ? left : right;
    end
  endfunction

  // 반복문을 담은 function도 조합 논리가 된다.
  function [4:0] count_leading_zeros;
    input [31:0] value;
    integer index;
    begin
      count_leading_zeros = 5'd0;
      for (index = 31; index >= 0; index = index - 1) begin
        if (value[index] === 1'b0 && count_leading_zeros == (31 - index))
          count_leading_zeros = count_leading_zeros + 5'd1;
      end
    end
  endfunction

  assign max_unsigned  = pick_larger_unsigned(a, b);
  assign max_signed    = pick_larger_signed(a, b);
  assign leading_zeros = count_leading_zeros(a);

endmodule
