// 예제 6-1의 testbench. 계층 이름으로 내부 신호를 관찰한다.
`timescale 1ns/1ps

module tb_ex01;

  reg  [7:0] a, b;
  wire [7:0] sum;
  wire       carry_out;
  integer    i, j;

  ex01_hierarchy dut(.a(a), .b(b), .sum(sum), .carry_out(carry_out));

  initial begin
    $display("--- 계층 이름으로 내부 신호를 읽는다 ---");
    a = 8'h0f; b = 8'h01;
    #1;
    $display("a=%h b=%h -> sum=%h carry=%b", a, b, sum, carry_out);
    // 점으로 계층을 내려가며 내부 신호에 접근한다.
    $display("dut.middle_carry            = %b", dut.middle_carry);
    $display("dut.u_low.carry_chain       = %b", dut.u_low.carry_chain);
    $display("dut.u_low.u_bit3.carry_out  = %b", dut.u_low.u_bit3.carry_out);

    $display("--- 전수 검사 ---");
    for (i = 0; i < 256; i = i + 1) begin
      for (j = 0; j < 256; j = j + 1) begin
        a = i[7:0];
        b = j[7:0];
        #1;
        if ({carry_out, sum} !== ({1'b0, a} + {1'b0, b}))
          $fatal(1, "FAIL a=%h b=%h sum=%h carry=%b expected=%h",
                 a, b, sum, carry_out, ({1'b0, a} + {1'b0, b}));
      end
    end

    $display("PASS ch06 ex01 hierarchy, 65536 vectors");
    $finish(0);
  end

endmodule
