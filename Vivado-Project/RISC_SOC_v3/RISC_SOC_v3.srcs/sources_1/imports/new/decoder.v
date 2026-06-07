`timescale 1ns/1ps
`include "defines.vh"

module decoder (
    input  wire [`INSTR_WIDTH-1:0] instr,

    output wire [5:0]              opcode,
    output wire [`REG_ADDR_W-1:0] rs1,
    output wire [`REG_ADDR_W-1:0] rs2,
    output wire [`REG_ADDR_W-1:0] rd,

    output wire [3:0]              funct,
    output wire [25:0]             jump_target
);

    // --------------------------------------------------------
    // Instruction field extraction
    // --------------------------------------------------------

    assign opcode      = instr[`OPCODE_MSB:`OPCODE_LSB];

    assign rs1         = instr[`RS1_MSB:`RS1_LSB];
    assign rs2         = instr[`RS2_MSB:`RS2_LSB];

    // R-type and I-type destination register selection
    assign rd = (opcode == `OP_RTYPE) ?
                instr[`RD_R_MSB:`RD_R_LSB] :
                instr[`RD_I_MSB:`RD_I_LSB];

    // Lower 4 bits used as function field
    assign funct       = instr[3:0];

    // Jump target field
    assign jump_target = instr[`JADDR_MSB:`JADDR_LSB];

endmodule