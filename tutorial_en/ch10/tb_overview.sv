`timescale 1ns/1ps

module tb_overview;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic [3:0] a, b;
    logic select_b, d;
    logic [1:0] op;
    logic [3:0] inv_y, sum, mux_y, alu_y;
    logic carry, q, zero;

    inv4 u_inv(.a(a), .y(inv_y));
    add4 u_add(.a(a), .b(b), .sum(sum), .carry(carry));
    mux4 u_mux(.a(a), .b(b), .select_b(select_b), .y(mux_y));
    dff1 u_dff(.clk(clk), .reset(reset), .d(d), .q(q));
    mini_alu u_alu(.a(a), .b(b), .op(op), .y(alu_y), .zero(zero));

    always #5 clk = ~clk;

    task expect4(input [8*24-1:0] name, input [3:0] actual, input [3:0] expected);
        if (actual !== expected)
            $fatal(1, "FAIL %0s expected=%h actual=%h", name, expected, actual);
    endtask

    initial begin
        $dumpfile("build/overview.vcd");
        $dumpvars(0, tb_overview);

        a = 4'h3; b = 4'h5; select_b = 1'b0; d = 1'b0; op = 2'b00;
        #1;
        expect4("inverter", inv_y, 4'hc);
        expect4("adder sum", sum, 4'h8);
        if (carry !== 1'b0) $fatal(1, "FAIL adder carry");
        expect4("mux a", mux_y, 4'h3);
        expect4("alu add", alu_y, 4'h8);

        a = 4'hf; b = 4'h1; select_b = 1'b1; op = 2'b01;
        #1;
        expect4("adder wrap", sum, 4'h0);
        if (carry !== 1'b1) $fatal(1, "FAIL adder carry wrap");
        expect4("mux b", mux_y, 4'h1);
        expect4("alu subtract", alu_y, 4'he);

        @(posedge clk); #1;
        if (q !== 1'b0) $fatal(1, "FAIL reset state");
        reset = 1'b0; d = 1'b1;
        @(posedge clk); #1;
        if (q !== 1'b1) $fatal(1, "FAIL captured state");

        a = 4'ha; b = 4'h5; op = 2'b10; #1;
        expect4("alu and", alu_y, 4'h0);
        if (zero !== 1'b1) $fatal(1, "FAIL zero flag");

        $display("PASS ch10 통합 예제");
        $finish(0);
    end
endmodule
