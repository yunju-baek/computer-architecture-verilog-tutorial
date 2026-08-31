// 예제 5-3의 testbench. 우선순위를 조합마다 확인한다.
`timescale 1ns/1ps

module tb_ex03;

  reg         clk = 1'b0;
  reg         reset, load, enable;
  reg  [31:0] load_value;
  wire [31:0] state;

  ex03_control dut(.clk(clk), .reset(reset), .load(load), .enable(enable),
                   .load_value(load_value), .state(state));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk);
      #1;
    end
  endtask

  initial begin
    load_value = 32'h0000_1000;

    // 리셋
    reset = 1'b1; load = 1'b0; enable = 1'b0;
    step;
    $display("reset=1                    -> state=%h", state);
    if (state !== 32'h0) $fatal(1, "FAIL reset state=%h", state);

    // enable만 켠다. 4씩 진행한다.
    reset = 1'b0; enable = 1'b1;
    step;
    $display("enable=1                   -> state=%h", state);
    step;
    $display("enable=1                   -> state=%h", state);
    if (state !== 32'h8) $fatal(1, "FAIL enable state=%h", state);

    // load가 enable을 이긴다.
    load = 1'b1;
    step;
    $display("load=1 enable=1            -> state=%h  load가 우선한다", state);
    if (state !== 32'h1000) $fatal(1, "FAIL load state=%h", state);

    // reset이 모두를 이긴다.
    reset = 1'b1;
    step;
    $display("reset=1 load=1 enable=1    -> state=%h  reset이 우선한다", state);
    if (state !== 32'h0) $fatal(1, "FAIL reset 우선 state=%h", state);

    // 모두 끄면 값을 유지한다.
    reset = 1'b0; load = 1'b0; enable = 1'b1;
    step; step;
    $display("enable=1 두 사이클          -> state=%h", state);
    enable = 1'b0;
    step; step;
    $display("모두 0으로 두 사이클        -> state=%h  값을 유지한다", state);
    if (state !== 32'h8) $fatal(1, "FAIL 유지 state=%h", state);

    $display("PASS ch05 ex03 control");
    $finish(0);
  end

endmodule
