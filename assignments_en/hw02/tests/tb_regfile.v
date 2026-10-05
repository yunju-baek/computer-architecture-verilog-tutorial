`timescale 1ns/1ps
module tb_regfile;
 reg clk=0,we=0;reg[4:0]rs1=0,rs2=0,rd=0;reg[31:0]wd=0;wire[31:0]rv1,rv2;
 reg[3:0]case_id;
 regfile dut(clk,we,rs1,rs2,rd,wd,rv1,rv2);always #5 clk=~clk;
 task write;input[4:0]r;input[31:0]v;begin rd=r;wd=v;we=1;@(posedge clk);#1;we=0;end endtask
 initial begin $dumpfile("build/regfile.vcd");$dumpvars(0,tb_regfile);
  case_id=1;write(1,32'h12345678);case_id=2;write(31,32'hdeadbeef);case_id=3;rs1=1;rs2=31;#1;
  if(rv1!==32'h12345678||rv2!==32'hdeadbeef)$fatal(1,"FAIL normal read");
  case_id=4;write(0,32'hffffffff);rs1=0;#1;if(rv1!==0)$fatal(1,"FAIL x0");
  case_id=5;rd=1;wd=32'ha5a5a5a5;we=0;@(posedge clk);#1;rs1=1;#1;if(rv1!==32'h12345678)$fatal(1,"FAIL write enable");
  $display("PASS tb_regfile");$finish;
 end
endmodule
