`timescale 1ns/1ps
`include "defines.vh"

module alu (
    input  wire [`DATA_WIDTH-1:0] a,
    input  wire [`DATA_WIDTH-1:0] b,
    input  wire [3:0]             alu_op,
    output reg  [`DATA_WIDTH-1:0] result,
    output wire                   zero
);

always @(*) begin
    case (alu_op)

        `ALU_ADD:  result = a + b;
        `ALU_SUB:  result = a - b;
        `ALU_AND:  result = a & b;
        `ALU_OR:   result = a | b;
        `ALU_XOR:  result = a ^ b;
        `ALU_MUL:  result = a * b;

        `ALU_DIV: begin
            if (b != 0)
                result = a / b;
            else
                result = 32'hFFFF_FFFF;
        end

        `ALU_MOD: begin
            if (b != 0)
                result = a % b;
            else
                result = 32'hFFFF_FFFF;
        end

        `ALU_SLL:  result = a << b[4:0];
        `ALU_SRL:  result = a >> b[4:0];
        `ALU_SRA:  result = $signed(a) >>> b[4:0];

        `ALU_SLT: begin
            result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
        end

        `ALU_SLTU: begin
            result = (a < b) ? 32'd1 : 32'd0;
        end

        `ALU_PASS: result = b;

        default: result = 32'd0;

    endcase
end

assign zero = (result == 32'd0);

endmodule