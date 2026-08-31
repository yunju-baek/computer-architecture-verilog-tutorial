// 예제 5-4의 testbench. 두 리셋의 반응 시점을 대조한다.
`timescale 1ns/1ps

module tb_ex04;

  reg        clk = 1'b0;
  reg        reset;
  wire [3:0] sync_count, async_count;

  sync_reset_counter  u_sync (.clk(clk), .reset(reset), .count(sync_count));
  async_reset_counter u_async(.clk(clk), .reset(reset), .count(async_count));

  always #5 clk = ~clk;

  initial begin
    $timeformat(-9, 0, "ns", 6);

    reset = 1'b1;
    @(posedge clk); #1;
    reset = 1'b0;

    // 두 카운터를 함께 진행시킨다.
    repeat (5) @(posedge clk);
    #1;
    $display("%t  sync=%0d async=%0d  두 카운터가 함께 진행한다",
             $time, sync_count, async_count);

    // clock 에지 사이에서 reset을 올린다.
    @(negedge clk);
    #1 reset = 1'b1;
    #1;
    $display("%t  sync=%0d async=%0d  비동기 리셋이 즉시 반응한다",
             $time, sync_count, async_count);
    if (async_count !== 4'd0) $fatal(1, "FAIL async_count=%0d", async_count);

    // 다음 에지에서 동기 리셋이 반응한다.
    @(posedge clk); #1;
    $display("%t  sync=%0d async=%0d  동기 리셋은 에지에서 반응한다",
             $time, sync_count, async_count);
    if (sync_count !== 4'd0) $fatal(1, "FAIL sync_count=%0d", sync_count);

    // 폭 순환 확인
    reset = 1'b0;
    repeat (16) @(posedge clk);
    #1;
    $display("%t  sync=%0d  4비트 카운터는 16사이클마다 0으로 돌아온다",
             $time, sync_count);
    if (sync_count !== 4'd0) $fatal(1, "FAIL 순환 sync_count=%0d", sync_count);

    $display("PASS ch05 ex04 reset");
    $finish(0);
  end

endmodule
