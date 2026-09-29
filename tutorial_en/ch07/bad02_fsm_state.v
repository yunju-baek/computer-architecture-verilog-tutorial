// 의도적 함정 2. FSM에서 기본값 배정과 default 분기를 빠뜨린다.
`timescale 1ns/1ps

module leaky_fsm(
  input  wire clk,
  input  wire reset,
  input  wire bit_in,
  output reg  detected
);
  localparam [1:0] IDLE = 2'd0, SAW_ONE = 2'd1, SAW_TWO = 2'd2, SAW_MANY = 2'd3;

  reg [1:0] state, next_state;

  always @(posedge clk) begin
    if (reset) state <= IDLE;
    else       state <= next_state;
  end

  always @* begin
    // 기본값 배정을 빠뜨렸다.
    case (state)
      IDLE:     if (bit_in) next_state = SAW_ONE;
                else        next_state = IDLE;
      SAW_ONE:  if (bit_in) next_state = SAW_TWO;
                else        next_state = IDLE;
      SAW_TWO:  if (bit_in) next_state = SAW_MANY;
                else        next_state = IDLE;
      SAW_MANY: begin
                  detected = 1'b1;        // 이 분기에서만 detected를 배정한다
                  if (bit_in) next_state = SAW_MANY;
                  else        next_state = IDLE;
                end
      default:  next_state = IDLE;
    endcase
  end
endmodule

module bad02_fsm_state;
  reg  clk = 1'b0;
  reg  reset, bit_in;
  wire detected;
  integer step;
  reg [11:0] pattern = 12'b0110_1110_1111;

  leaky_fsm dut(.clk(clk), .reset(reset), .bit_in(bit_in), .detected(detected));

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1; bit_in = 1'b0;
    @(posedge clk); #1;
    reset = 1'b0;

    $display("step in state detected");
    $display("----------------------");
    for (step = 11; step >= 0; step = step - 1) begin
      bit_in = pattern[step];
      #1;
      $display(" %2d   %b    %0d      %b", 11 - step, bit_in, dut.state, detected);
      @(posedge clk);
    end
    $display("detected가 x로 시작하고 한 번 1이 되면 그 값을 유지한다");
    $finish(0);
  end
endmodule
