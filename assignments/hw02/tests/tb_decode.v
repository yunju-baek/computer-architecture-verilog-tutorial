`timescale 1ns/1ps
module tb_decode;
 reg[31:0]i;wire[2:0]s;wire asi,rw,mw,mr,j,ill;wire[1:0]br;wire[3:0]op;wire[31:0]imm;
 reg[3:0]case_id;
 rv32i_decode d(i,s,asi,rw,mw,mr,br,j,op,ill);rv32i_immgen g(i,s,imm);
 task ck;input[31:0]ii,im;input[2:0]ss;input[3:0]oo;input rr,ww,mm,jj,xx;input[1:0]bb;begin i=ii;#1;
  if(s!==ss||op!==oo||rw!==rr||mw!==ww||mr!==mm||j!==jj||ill!==xx||br!==bb||(!xx&&imm!==im))begin $display("FAIL decode i=%h imm=%h s=%d op=%d controls=%b%b%b%b%b br=%d",i,imm,s,op,rw,mw,mr,j,ill,br);$fatal(1);end end endtask
 initial begin $dumpfile("build/decode.vcd");$dumpvars(0,tb_decode);
  case_id=1;ck(32'hfff00093,32'hffffffff,0,0,1,0,0,0,0,0); // addi x1,x0,-1
  case_id=2;ck(32'h002081b3,2,0,0,1,0,0,0,0,0); // add x3,x1,x2 (imm output is don't-care)
  case_id=3;ck(32'h40310233,32'h403,0,1,1,0,0,0,0,0); // sub x4,x2,x3 (imm output is don't-care)
  case_id=4;ck(32'h0040a023,0,1,0,0,1,0,0,0,0); // sw x4,0(x1)
  case_id=5;ck(32'h0000a283,0,0,0,1,0,1,0,0,0); // lw x5,0(x1)
  case_id=6;ck(32'h00208463,8,2,1,0,0,0,0,0,1); // beq +8
  case_id=7;ck(32'h12345337,32'h12345000,3,10,1,0,0,0,0,0); // lui
  case_id=8;ck(32'h008000ef,8,4,0,1,0,0,1,0,0); // jal
  case_id=9;ck(32'hffffffff,0,0,0,0,0,0,0,1,0);
  $display("PASS tb_decode");$finish;
 end
endmodule
