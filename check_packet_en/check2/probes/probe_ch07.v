// Check 2-2. CH07 Memory Read Timing and FSM.
// Target: tutorial/ch07/ex02_sync_read.v (comb_read_memory, sync_read_memory),
//         tutorial/ch07/ex04_fsm.v
//
// Inputs update on clock falling edge; states are sampled at #1 after clock rising edge.
`timescale 1ns/1ps

module probe_ch07;
  `include "lcg.vh"
  `include "check.vh"
  `include "predictions.vh"

  reg  [31:0] sid, s1, s2, s3, s4;
  reg         clk = 1'b0;

  // Two memory models receiving identical input stimuli.
  reg         write_enable;
  reg  [3:0]  addr;
  reg  [7:0]  write_data;
  wire [7:0]  comb_data, sync_data;
  reg  [3:0]  mem_addr;
  reg  [7:0]  d1, d2;
  reg  [7:0]  comb_after_2, sync_after_2, sync_after_3;

  // FSM
  reg         reset, bit_in;
  wire        detected;
  reg  [7:0]  seq;
  integer     detect_count, i;
  reg  [1:0]  final_state;

  integer     fails;

  comb_read_memory comb_mem(.clk(clk), .write_enable(write_enable), .addr(addr),
                            .write_data(write_data), .read_data(comb_data));
  sync_read_memory sync_mem(.clk(clk), .write_enable(write_enable), .addr(addr),
                            .write_data(write_data), .read_data(sync_data));
  ex04_fsm fsm(.clk(clk), .reset(reset), .bit_in(bit_in), .detected(detected));

  always #5 clk = ~clk;

  task step;
    begin
      @(posedge clk); #1;
    end
  endtask

  initial begin
    fails = 0;
    read_student_id(sid);

    // Input derivation: salt 0x5A5A0700
    s1 = lcg_next(sid ^ 32'h5A5A0700);
    s2 = lcg_next(s1);
    s3 = lcg_next(s2);
    s4 = lcg_next(s3);
    mem_addr = s1[31:28];
    d1       = s2[31:24];
    d2       = s3[31:24];
    if (d2 == d1) d2 = ~d1;               // Ensure distinct values
    seq      = s4[31:24];

    $display("=== probe_ch07 STUDENT_ID=%0d ===", sid);
    $display("INPUT memory: addr=%h  d1=%h  d2=%h", mem_addr, d1, d2);
    $display("      Edge 1: write_enable=1 addr=%h write_data=d1", mem_addr);
    $display("      Edge 2: write_enable=1 addr=%h write_data=d2   -> Observe comb_data, sync_data afterward", mem_addr);
    $display("      Edge 3: write_enable=0 addr=%h                 -> Observe sync_data afterward", mem_addr);
    $display("INPUT fsm: bit_in sequence after 1 reset edge = %b (8 edges MSB-first), counting detected assertions", seq);

    // ---- Memory ----
    reset = 1'b1; bit_in = 1'b0;
    @(negedge clk);
    write_enable = 1'b1; addr = mem_addr; write_data = d1;
    step;                                              // Edge 1
    @(negedge clk);
    write_enable = 1'b1; addr = mem_addr; write_data = d2;
    step;                                              // Edge 2
    comb_after_2 = comb_data;
    sync_after_2 = sync_data;
    @(negedge clk);
    write_enable = 1'b0;
    step;                                              // Edge 3
    sync_after_3 = sync_data;

    // ---- FSM ----
    @(negedge clk);
    reset = 1'b1;
    step;                                              // Reset edge
    @(negedge clk);
    reset = 1'b0;
    detect_count = 0;
    for (i = 7; i >= 0; i = i - 1) begin
      bit_in = seq[i];
      step;
      if (detected === 1'b1) detect_count = detect_count + 1;
      @(negedge clk);
    end
    final_state = fsm.state;

    `CHECK ("CH07_COMB_AFTER_2",  `P_CH07_COMB_AFTER_2,  comb_after_2)
    `CHECK ("CH07_SYNC_AFTER_2",  `P_CH07_SYNC_AFTER_2,  sync_after_2)
    `CHECK ("CH07_SYNC_AFTER_3",  `P_CH07_SYNC_AFTER_3,  sync_after_3)
    `CHECKD("CH07_DETECT_COUNT",  `P_CH07_DETECT_COUNT,  detect_count)
    `CHECK ("CH07_FINAL_STATE",   `P_CH07_FINAL_STATE,   final_state)
    `FINISH_CHECK("ch07", sid)
  end
endmodule
