`timescale 1ns/1ps

module inv4(input logic [3:0] a, output logic [3:0] y);
    assign y = ~a;
endmodule

module add4(
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [3:0] sum,
    output logic       carry
);
    assign {carry, sum} = a + b;
endmodule

module mux4(
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       select_b,
    output logic [3:0] y
);
    always_comb begin
        y = a;
        if (select_b)
            y = b;
    end
endmodule

module dff1(
    input  logic clk,
    input  logic reset,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

module mini_alu(
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [1:0] op,
    output logic [3:0] y,
    output logic       zero
);
    always_comb begin
        case (op)
            2'b00: y = a + b;
            2'b01: y = a - b;
            2'b10: y = a & b;
            default: y = a | b;
        endcase
        zero = (y == 4'b0000);
    end
endmodule
