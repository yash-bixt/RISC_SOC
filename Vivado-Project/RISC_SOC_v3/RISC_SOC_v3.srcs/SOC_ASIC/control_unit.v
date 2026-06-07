`timescale 1ns/1ps
`include "defines.vh"

module control_unit (
    input  wire [5:0] opcode,

    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch_eq,
    output reg        branch_ne,
    output reg        jump,
    output reg        lui,
    output reg        halt,

    output reg [1:0]  alu_op_type
);

always @(*) begin
    reg_write   = 0;
    mem_read    = 0;
    mem_write   = 0;
    mem_to_reg  = 0;
    alu_src     = 0;
    branch_eq   = 0;
    branch_ne   = 0;
    jump        = 0;
    lui         = 0;
    halt        = 0;
    alu_op_type = 2'b00;

    case (opcode)

        `OP_RTYPE: begin
            reg_write   = 1;
            alu_op_type = 2'b10;
        end

        `OP_ADDI: begin
            reg_write   = 1;
            alu_src     = 1;
            alu_op_type = 2'b00;
        end

        `OP_LW: begin
            reg_write   = 1;
            mem_read    = 1;
            mem_to_reg  = 1;
            alu_src     = 1;
            alu_op_type = 2'b00;
        end

        `OP_SW: begin
            mem_write   = 1;
            alu_src     = 1;
            alu_op_type = 2'b00;
        end

        `OP_BEQ: begin
            branch_eq   = 1;
            alu_op_type = 2'b01;
        end

        `OP_BNE: begin
            branch_ne   = 1;
            alu_op_type = 2'b01;
        end

        `OP_J: begin
            jump = 1;
        end

        `OP_LUI: begin
            reg_write = 1;
            lui       = 1;
        end

        `OP_HALT: begin
            halt = 1;
        end

        default: begin
        end

    endcase
end

endmodule