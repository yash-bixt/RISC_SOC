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
    reg_write   = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 1'b0;
    alu_src     = 1'b0;
    branch_eq   = 1'b0;
    branch_ne   = 1'b0;
    jump        = 1'b0;
    lui         = 1'b0;
    halt        = 1'b0;
    alu_op_type = 2'b00;

    case (opcode)

        `OP_RTYPE: begin
            reg_write   = 1'b1;
            alu_op_type = 2'b10;
        end

        `OP_ADDI: begin
            reg_write   = 1'b1;
            alu_src     = 1'b1;
            alu_op_type = 2'b00;
        end

        `OP_LW: begin
            reg_write   = 1'b1;
            mem_read    = 1'b1;
            mem_to_reg  = 1'b1;
            alu_src     = 1'b1;
            alu_op_type = 2'b00;
        end

        `OP_SW: begin
            mem_write   = 1'b1;
            alu_src     = 1'b1;
            alu_op_type = 2'b00;
        end

        `OP_BEQ: begin
            branch_eq   = 1'b1;
            alu_op_type = 2'b01;
        end

        `OP_BNE: begin
            branch_ne   = 1'b1;
            alu_op_type = 2'b01;
        end

        `OP_J: begin
            jump = 1'b1;
        end

        `OP_LUI: begin
            reg_write = 1'b1;
            lui       = 1'b1;
        end

        `OP_HALT: begin
            halt = 1'b1;
        end

        default: begin
            reg_write   = 1'b0;
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            mem_to_reg  = 1'b0;
            alu_src     = 1'b0;
            branch_eq   = 1'b0;
            branch_ne   = 1'b0;
            jump        = 1'b0;
            lui         = 1'b0;
            halt        = 1'b0;
            alu_op_type = 2'b00;
        end

    endcase
end

endmodule