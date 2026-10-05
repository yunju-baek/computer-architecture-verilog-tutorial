module rv32i_decode(
 input wire [31:0] instr, output reg [2:0] imm_sel, output reg alu_src_imm,
 output reg reg_write, output reg mem_write, output reg mem_to_reg,
 output reg [1:0] branch, output reg jump, output reg [3:0] alu_op, output reg illegal
);
 /* TODO */
endmodule
