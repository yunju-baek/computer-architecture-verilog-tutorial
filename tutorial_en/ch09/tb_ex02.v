// 예제 9-2의 testbench. 두 모듈의 값이 같은 것을 확인한다.
`timescale 1ns/1ps

module tb_ex02;

  reg        clk = 1'b0;
  reg        reset;
  wire [3:0] synth_count, sim_count;
  integer    step;

  counter_synthesizable  u_synth(.clk(clk), .reset(reset), .count(synth_count));
  counter_simulation_only u_sim (.clk(clk), .reset(reset), .count(sim_count));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1;
    @(posedge clk); #2;
    reset = 1'b0;

    $display("step | 합성 가능 시뮬레이션 전용");
    $display("-----+-------------------------");
    for (step = 0; step < 6; step = step + 1) begin
      @(posedge clk); #2;
      $display("  %0d  |    %0d          %0d", step, synth_count, sim_count);
      if (synth_count !== sim_count)
        $fatal(1, "FAIL step=%0d synth=%0d sim=%0d", step, synth_count, sim_count);
    end

    $display("시뮬레이션 값이 같으므로 시뮬레이션만으로는 두 코드를 구별하기 어렵다");
    $display("PASS ch09 ex02 대조");
    $finish(0);
  end

endmodule
