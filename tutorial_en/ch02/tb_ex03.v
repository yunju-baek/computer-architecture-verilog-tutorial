// 예제 2-3의 testbench. 두 방식의 결과가 모든 입력에서 같음을 확인한다.
`timescale 1ns/1ps

module tb_ex03;

  reg  [3:0] a, b;
  reg        sel;
  wire [3:0] y_assign, y_always;
  integer    i;

  mux_with_assign u_assign(.a(a), .b(b), .sel(sel), .y(y_assign));
  mux_with_always u_always(.a(a), .b(b), .sel(sel), .y(y_always));

  initial begin
    for (i = 0; i < 512; i = i + 1) begin
      a   = i[3:0];
      b   = i[7:4];
      sel = i[8];
      #1;
      if (y_assign !== y_always)
        $fatal(1, "FAIL 두 방식의 결과가 다르다 a=%h b=%h sel=%b assign=%h always=%h",
               a, b, sel, y_assign, y_always);
      if (y_assign !== (sel ? b : a))
        $fatal(1, "FAIL 기대값과 다르다 a=%h b=%h sel=%b y=%h", a, b, sel, y_assign);
    end
    $display("PASS ch02 ex03 wire/reg, 512 vectors");
    $finish(0);
  end

endmodule
