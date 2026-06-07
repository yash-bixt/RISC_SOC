`timescale 1ns/1ps
`include "defines.vh"

module immediate_generator (
    input  wire [`INSTR_WIDTH-1:0] instr,
    output wire [`DATA_WIDTH-1:0]  imm_ext
);

    // Extract 16-bit immediate field
    wire [15:0] imm16;

    assign imm16 = instr[`IMM_MSB:`IMM_LSB];

    // Sign-extension to 32 bits
    assign imm_ext = {{16{imm16[15]}}, imm16};

endmodule