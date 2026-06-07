`timescale 1ns/1ps
`include "defines.vh"

module alu_control (
    input  wire [1:0] alu_op_type,
    input  wire [3:0] funct,
    output reg  [3:0] alu_op
);

always @(*) begin
    alu_op = `ALU_PASS;

    case (alu_op_type)

        2'b00: begin
            alu_op = `ALU_ADD;
        end

        2'b01: begin
            alu_op = `ALU_SUB;
        end

        2'b10: begin
            case (funct)
                `FUNCT_ADD:  alu_op = `ALU_ADD;
                `FUNCT_SUB:  alu_op = `ALU_SUB;
                `FUNCT_AND:  alu_op = `ALU_AND;
                `FUNCT_OR:   alu_op = `ALU_OR;
                `FUNCT_XOR:  alu_op = `ALU_XOR;
                `FUNCT_MUL:  alu_op = `ALU_MUL;

                // Disabled for first ASIC version
                `FUNCT_DIV:  alu_op = `ALU_PASS;
                `FUNCT_MOD:  alu_op = `ALU_PASS;

                `FUNCT_SLL:  alu_op = `ALU_SLL;
                `FUNCT_SRL:  alu_op = `ALU_SRL;
                `FUNCT_SRA:  alu_op = `ALU_SRA;
                `FUNCT_SLT:  alu_op = `ALU_SLT;
                `FUNCT_SLTU: alu_op = `ALU_SLTU;

                default:     alu_op = `ALU_PASS;
            endcase
        end

        default: begin
            alu_op = `ALU_PASS;
        end

    endcase
end

endmodule