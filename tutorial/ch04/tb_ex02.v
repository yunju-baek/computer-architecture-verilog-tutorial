// 예제 4-2의 testbench. 두 방식이 모든 opcode에서 같은 결과를 내는지 확인한다.
`timescale 1ns/1ps

module tb_ex02;

  reg  [3:0] opcode;
  wire [1:0] sel_a, sel_b;
  wire       we_a, we_b, mr_a, mr_b, il_a, il_b;
  integer    i;

  with_default       u_a(.opcode(opcode), .alu_select(sel_a),
                        .write_enable(we_a), .memory_read(mr_a), .illegal(il_a));
  with_full_branches u_b(.opcode(opcode), .alu_select(sel_b),
                        .write_enable(we_b), .memory_read(mr_b), .illegal(il_b));

  initial begin
    $display("opcode | sel we mr il");
    $display("-------+------------");
    for (i = 0; i < 16; i = i + 1) begin
      opcode = i[3:0];
      #1;
      if (i < 6)
        $display("   %h   |  %b  %b  %b  %b", opcode, sel_a, we_a, mr_a, il_a);

      if (sel_a !== sel_b || we_a !== we_b || mr_a !== mr_b || il_a !== il_b)
        $fatal(1, "FAIL 두 방식의 결과가 다르다 opcode=%h", opcode);
    end
    $display("PASS ch04 ex02 default, 16 opcodes");
    $finish(0);
  end

endmodule
