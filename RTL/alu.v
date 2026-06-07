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
    result = {`DATA_WIDTH{1'b0}};

    case (alu_op)

        `ALU_ADD:  result = a + b;
        `ALU_SUB:  result = a - b;
        `ALU_AND:  result = a & b;
        `ALU_OR:   result = a | b;
        `ALU_XOR:  result = a ^ b;

        `ALU_MUL:  result = a * b;

        // ASIC-safe placeholder for now
        `ALU_DIV:  result = 32'h0000_0000;
        `ALU_MOD:  result = 32'h0000_0000;

        `ALU_SLL:  result = a << b[4:0];
        `ALU_SRL:  result = a >> b[4:0];
        `ALU_SRA:  result = $signed(a) >>> b[4:0];

        `ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
        `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;

        `ALU_PASS: result = b;

        default:   result = {`DATA_WIDTH{1'b0}};

    endcase
end

assign zero = (result == {`DATA_WIDTH{1'b0}});

endmodule