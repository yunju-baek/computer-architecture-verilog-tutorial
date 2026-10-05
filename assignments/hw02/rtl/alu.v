module alu(
    input wire [31:0] a, input wire [31:0] b, input wire [3:0] op,
    output reg [31:0] result, output wire zero,
    output reg carry, output reg overflow
);
    // Provided flag logic. Implement only the result selection below.
    wire [32:0] add_ext = {1'b0,a} + {1'b0,b};
    wire [32:0] sub_ext = {1'b0,a} + {1'b0,~b} + 33'b1;
    always @* begin
        carry = 1'b0;
        overflow = 1'b0;
        if (op == 4'h0) begin
            carry = add_ext[32];
            overflow = (~(a[31]^b[31])) & (add_ext[31]^a[31]);
        end else if (op == 4'h1) begin
            carry = sub_ext[32];
            overflow = (a[31]^b[31]) & (sub_ext[31]^a[31]);
        end
    end
    always @* begin
        result = 32'b0;
        // TODO HW02: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU.
        // Operation codes: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 respectively.
        // Shift amount: b[4:0]. Default result: 0.
    end
    assign zero = (result == 32'b0);
endmodule
