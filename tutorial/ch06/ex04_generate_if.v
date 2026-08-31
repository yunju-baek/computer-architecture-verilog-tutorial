// 예제 6-4. generate if로 파라미터에 따라 구현을 고른다.
`timescale 1ns/1ps

module ex04_shifter #(
  parameter USE_BARREL = 1     // 1이면 한 번에, 0이면 단계별로 시프트한다
)(
  input  wire [7:0] value,
  input  wire [2:0] amount,
  output wire [7:0] result
);

  generate
    if (USE_BARREL) begin : barrel
      // 시프트 연산자 하나로 표현한다.
      assign result = value << amount;
    end
    else begin : staged
      // 단계 3개를 이어 붙인다. 각 단계가 amount의 비트 하나를 본다.
      wire [7:0] stage1, stage2;
      assign stage1 = amount[0] ? {value[6:0],  1'b0}  : value;
      assign stage2 = amount[1] ? {stage1[5:0], 2'b0}  : stage1;
      assign result = amount[2] ? {stage2[3:0], 4'b0}  : stage2;
    end
  endgenerate

endmodule
