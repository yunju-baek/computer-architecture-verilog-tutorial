`timescale 1ns/1ps
module tb_pc_counter;
 reg clk=0,reset=0,load=0,enable=0; reg [31:0] load_value=0; wire [31:0] value;
 reg[3:0]case_id;
 pc_counter dut(clk,reset,load,enable,load_value,value); always #5 clk=~clk;
 task edge_expect; input [31:0] exp; begin @(posedge clk);#1;if(value!==exp) begin $display("FAIL PC got=%h expected=%h",value,exp);$fatal(1);end end endtask
 initial begin $dumpfile("build/pc.vcd");$dumpvars(0,tb_pc_counter);
   case_id=1;reset=1; edge_expect(0);
   case_id=2;reset=0; enable=1; edge_expect(4);
   case_id=3;edge_expect(8);
   case_id=4;enable=0; edge_expect(8);
   case_id=5;load=1;enable=1;load_value=32'h24;edge_expect(32'h24);
   case_id=6;load=0;edge_expect(32'h28);
   case_id=7;reset=1;load=1;load_value=32'hff;edge_expect(0);
   $display("PASS tb_pc_counter");$finish;
 end
endmodule
