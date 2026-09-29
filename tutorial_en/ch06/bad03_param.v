// 의도적 함정 3. parameter 전달을 빠뜨리고 기본값에 의존한다.
`timescale 1ns/1ps

module counter #(
  parameter WIDTH = 4        // 기본값이 4다
)(
  input  wire             clk,
  input  wire             reset,
  output reg  [WIDTH-1:0] count
);
  always @(posedge clk) begin
    if (reset) count <= {WIDTH{1'b0}};
    else       count <= count + 1'b1;
  end
endmodule

module bad03_param;
  reg        clk = 1'b0;
  reg        reset;
  wire [7:0] wide_count;     // 8비트를 기대한다
  wire [7:0] correct_count;

  always #5 clk = ~clk;

  // WIDTH 전달을 빠뜨렸다. 기본값 4가 쓰이므로 4비트만 세고 상위 4비트는 0으로 채워진다.
  counter u_default(.clk(clk), .reset(reset), .count(wide_count));

  // WIDTH를 명시했다.
  counter #(.WIDTH(8)) u_explicit(.clk(clk), .reset(reset), .count(correct_count));

  initial begin
    reset = 1'b1;
    @(posedge clk); #1;
    reset = 1'b0;

    repeat (20) @(posedge clk);
    #1;
    $display("20사이클 뒤");
    $display("WIDTH 전달 누락 -> count=%h  16사이클마다 순환하고 상위 4비트는 0이 된다", wide_count);
    $display("WIDTH 명시     -> count=%h", correct_count);
    $finish(0);
  end
endmodule
