`timescale 1ns/1ps
module tb_student_blocks;
  reg clk=0;
  integer checks;
  reg[3:0]case_id;

  reg pc_reset=0,pc_load=0,pc_enable=0;
  reg[31:0]pc_load_value=0;
  wire[31:0]pc_value;
  pc_counter pc(clk,pc_reset,pc_load,pc_enable,pc_load_value,pc_value);

  reg rf_we=0;reg[4:0]rf_rs1=0,rf_rs2=0,rf_rd=0;reg[31:0]rf_wd=0;
  wire[31:0]rf_rv1,rf_rv2;
  regfile rf(clk,rf_we,rf_rs1,rf_rs2,rf_rd,rf_wd,rf_rv1,rf_rv2);

  reg[31:0]instr=0;wire[2:0]imm_sel;wire alu_src_imm,reg_write,mem_write,mem_to_reg,jump,illegal;
  wire[1:0]branch;wire[3:0]alu_op;wire[31:0]imm;
  rv32i_decode dec(instr,imm_sel,alu_src_imm,reg_write,mem_write,mem_to_reg,branch,jump,alu_op,illegal);
  rv32i_immgen gen(instr,imm_sel,imm);

  always #5 clk=~clk;

  task check_pc;
    input tr,tl,te;input[31:0]tv,expected;
    begin pc_reset=tr;pc_load=tl;pc_enable=te;pc_load_value=tv;@(posedge clk);#1;
      if(pc_value!==expected)$fatal(1,"FAIL student PC case=%0d value=%h",case_id,pc_value);
      checks=checks+1;
    end
  endtask

  task check_write;
    input[4:0]target;input[31:0]value,expected;
    begin rf_rd=target;rf_wd=value;rf_we=1;@(posedge clk);#1;rf_we=0;rf_rs1=target;#1;
      if(rf_rv1!==expected)$fatal(1,"FAIL student RF case=%0d value=%h",case_id,rf_rv1);
      checks=checks+1;
    end
  endtask

  task check_decode;
    input[31:0]ti,timm;input tasi,trw,tmw,tmr,tj,till;input[1:0]tbr;input[3:0]top;
    begin instr=ti;#1;
      if(imm!==timm||alu_src_imm!==tasi||reg_write!==trw||mem_write!==tmw||
         mem_to_reg!==tmr||jump!==tj||illegal!==till||branch!==tbr||alu_op!==top)
        $fatal(1,"FAIL student decode case=%0d instr=%h imm=%h",case_id,instr,imm);
      checks=checks+1;
    end
  endtask

  initial begin
    $dumpfile("build/student_blocks.vcd");$dumpvars(0,tb_student_blocks);
    checks=0;case_id=0;
    /* TODO: call the tasks for at least six state and instruction cases. */
    if(checks<6)$fatal(1,"TODO add at least six student block cases");
    $display("PASS student block checks=%0d",checks);$finish;
  end
endmodule
