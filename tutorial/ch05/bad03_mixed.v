// 의도적 함정 3. 한 블록에서 두 대입을 섞는다.
// 읽는 사람이 각 신호의 갱신 시점을 추적해야 한다.
`timescale 1ns/1ps

module mixed_assignments(
  input  wire       clk,
  input  wire [3:0] d,
  output reg  [3:0] mixed_a,
  output reg  [3:0] mixed_b
);
  always @(posedge clk) begin
    mixed_a  = d + 4'd1;        // 블로킹. 즉시 반영된다
    mixed_b <= mixed_a + 4'd1;  // 논블로킹. 방금 대입한 mixed_a를 읽는다
  end
endmodule

module bad03_mixed;
  reg        clk = 1'b0;
  reg  [3:0] d;
  wire [3:0] mixed_a, mixed_b;

  mixed_assignments dut(.clk(clk), .d(d), .mixed_a(mixed_a), .mixed_b(mixed_b));

  always #5 clk = ~clk;

  initial begin
    d = 4'd0;
    @(posedge clk); #1;

    d = 4'd5;
    @(posedge clk); #1;
    $display("d=%0d -> mixed_a=%0d mixed_b=%0d", d, mixed_a, mixed_b);

    d = 4'd7;
    @(posedge clk); #1;
    $display("d=%0d -> mixed_a=%0d mixed_b=%0d", d, mixed_a, mixed_b);

    $display("한 블록에서 대입을 섞으면 갱신 시점을 코드 순서로 추적해야 한다");
    $finish(0);
  end
endmodule
