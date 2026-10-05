`timescale 1ns/1ps
module tb_alu;
    reg [31:0] a, b;
    reg [3:0] op;
    wire [31:0] result;
    wire zero, carry, overflow;
    reg [3:0] case_id;

    alu dut(a, b, op, result, zero, carry, overflow);

    task check;
        input [31:0] aa, bb, expected;
        input [3:0] operation;
        input expected_carry, expected_overflow;
        begin
            a = aa; b = bb; op = operation; #1;
            if (result !== expected || carry !== expected_carry || overflow !== expected_overflow)
                $fatal(1, "FAIL ALU op=%h a=%h b=%h result=%h carry=%b overflow=%b",
                       op, a, b, result, carry, overflow);
        end
    endtask

    initial begin
        $dumpfile("build/alu.vcd");
        $dumpvars(0, tb_alu);
        case_id=1;check(32'hffff_ffff, 32'h0000_0001, 32'h0000_0000, 4'h0, 1'b1, 1'b0);
        case_id=2;check(32'h7fff_ffff, 32'h0000_0001, 32'h8000_0000, 4'h0, 1'b0, 1'b1);
        case_id=3;check(32'h0000_0007, 32'h0000_0004, 32'h0000_0003, 4'h1, 1'b1, 1'b0);
        case_id=4;check(32'h8000_0000, 32'h0000_0001, 32'h0000_0001, 4'h8, 1'b0, 1'b0);
        case_id=5;check(32'hffff_ffff, 32'h0000_0000, 32'h0000_0000, 4'h9, 1'b0, 1'b0);
        case_id=6;check(32'hf0,32'h3c,32'h30,4'h2,0,0);
        case_id=7;check(32'hf0,32'h3c,32'hfc,4'h3,0,0);
        case_id=8;check(32'hf0,32'h3c,32'hcc,4'h4,0,0);
        case_id=9;check(32'h1,32'd33,32'h2,4'h5,0,0);
        case_id=10;check(32'h80000000,32'd1,32'h40000000,4'h6,0,0);
        case_id=11;check(32'h80000000,32'd1,32'hc0000000,4'h7,0,0);
        case_id=12;check(32'h80000000,32'd1,32'h7fffffff,4'h1,1,1);
        case_id=13;check(32'h12345678,32'hffffffff,32'b0,4'hf,0,0);
        if (zero !== 1'b1) $fatal(1, "FAIL ALU zero flag");
        $display("PASS HW02 ALU");
        $finish;
    end
endmodule
