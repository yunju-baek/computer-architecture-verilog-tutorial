// 예제 8-3. 경계값을 고르는 기준.
// 32비트 폭에서 전수 검사가 불가능할 때 무엇을 넣을지 정한다.
`timescale 1ns/1ps

module tb_ex03;

  reg         clk = 1'b0;
  reg         reset, enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  integer     index;

  // 경계값 목록. 표를 코드에 담아 두면 근거가 남는다.
  localparam VECTOR_COUNT = 10;
  reg [15:0] boundary_values [0:VECTOR_COUNT-1];

  ex01_dut dut(.clk(clk), .reset(reset), .enable(enable), .addend(addend),
               .total(total), .zero(zero), .carry(carry));

  always #5 clk = ~clk;

  task reset_dut;
    begin
      reset = 1'b1; enable = 1'b0; addend = 16'h0;
      @(posedge clk); #1;
      reset = 1'b0;
    end
  endtask

  initial begin
    // 경계값을 채운다. 각 값이 무엇을 확인하는지 주석으로 남긴다.
    boundary_values[0] = 16'h0000;   // 0
    boundary_values[1] = 16'h0001;   // 최소 양수
    boundary_values[2] = 16'h7fff;   // 부호 있는 최대
    boundary_values[3] = 16'h8000;   // 부호 있는 최소, 최상위 비트만 1
    boundary_values[4] = 16'hffff;   // 모든 비트 1
    boundary_values[5] = 16'hfffe;   // 최대에서 하나 아래
    boundary_values[6] = 16'h00ff;   // 하위 바이트만 1
    boundary_values[7] = 16'hff00;   // 상위 바이트만 1
    boundary_values[8] = 16'h5555;   // 비트가 번갈아 1
    boundary_values[9] = 16'haaaa;   // 반대로 번갈아 1

    $display("index value | total  zero carry");
    $display("------------+------------------");

    for (index = 0; index < VECTOR_COUNT; index = index + 1) begin
      reset_dut;
      enable = 1'b1;
      addend = boundary_values[index];
      @(posedge clk); #1;
      enable = 1'b0;

      $display("  %0d   %h |  %h    %b     %b",
               index, boundary_values[index], total, zero, carry);

      // 한 번만 더했으므로 total은 그 값과 같다.
      if (total !== boundary_values[index])
        $fatal(1, "FAIL index=%0d total=%h", index, total);
      // 값이 0일 때만 zero가 1이다.
      if (zero !== (boundary_values[index] == 16'h0))
        $fatal(1, "FAIL index=%0d zero=%b", index, zero);
      // 0에 더하므로 자리올림은 0으로 유지된다.
      if (carry !== 1'b0)
        $fatal(1, "FAIL index=%0d carry=%b", index, carry);
    end

    $display("PASS ch08 ex03 경계값 10개");
    $finish(0);
  end

endmodule
