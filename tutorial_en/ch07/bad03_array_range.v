// 의도적 함정 3. 배열 범위를 벗어난 주소로 접근한다.
`timescale 1ns/1ps

module small_memory(
  input  wire [3:0] addr,      // 주소 폭은 4비트라 16칸을 가리킨다
  output wire [7:0] data
);
  reg [7:0] storage [0:7];     // 칸은 8개뿐이다
  integer   index;

  initial begin
    for (index = 0; index < 8; index = index + 1)
      storage[index] = 8'h20 + index[7:0];
  end

  assign data = storage[addr];
endmodule

module bad03_array_range;
  reg  [3:0] addr;
  wire [7:0] data;
  integer    i;

  small_memory dut(.addr(addr), .data(data));

  initial begin
    #1;
    $display("addr | data");
    $display("-----+-----");
    for (i = 0; i < 16; i = i + 1) begin
      addr = i[3:0];
      #1;
      $display("  %h  |  %h", addr, data);
    end
    $display("주소 8부터는 배열 범위를 벗어나 x가 나온다");
    $display("주소 폭과 배열 칸 수를 함께 정하면 이 상황이 사라진다");
    $finish(0);
  end
endmodule
