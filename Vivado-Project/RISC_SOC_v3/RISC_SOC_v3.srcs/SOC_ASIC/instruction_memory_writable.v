`timescale 1ns/1ps
`include "defines.vh"

module instruction_memory_writable #(
    parameter DEPTH = 256
)(
    input  wire                         clk,
    input  wire                         rst,

    // CPU fetch port
    input  wire [`ADDR_WIDTH-1:0]       pc_addr,
    output reg  [`INSTR_WIDTH-1:0]      instr,

    // Loader write port
    input  wire                         load_we,
    input  wire [7:0]                   load_addr,
    input  wire [`INSTR_WIDTH-1:0]      load_data
);

    reg [`INSTR_WIDTH-1:0] imem [0:DEPTH-1];

    wire [7:0] word_addr;

    assign word_addr = pc_addr[9:2];

    // IMPORTANT:
    // Do NOT clear instruction memory on reset.
    // Otherwise UART-loaded instructions get erased.
    always @(posedge clk) begin
        if (load_we) begin
            imem[load_addr] <= load_data;
        end
    end

    // Async read for simple FPGA bring-up
    always @(*) begin
        instr = imem[word_addr];
    end

endmodule