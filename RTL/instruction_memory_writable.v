`timescale 1ns/1ps
`include "defines.vh"

module instruction_memory_writable #(
    parameter DEPTH = 256
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire [`ADDR_WIDTH-1:0]       pc_addr,
    output reg  [`INSTR_WIDTH-1:0]      instr,

    input  wire                         load_we,
    input  wire [7:0]                   load_addr,
    input  wire [`INSTR_WIDTH-1:0]      load_data
);

    reg [`INSTR_WIDTH-1:0] imem [0:DEPTH-1];

    wire [7:0] word_addr;
    assign word_addr = pc_addr[9:2];

    always @(posedge clk) begin
        if (rst) begin
            instr <= {`INSTR_WIDTH{1'b0}};
        end else begin
            if (load_we) begin
                imem[load_addr] <= load_data;
            end

            instr <= imem[word_addr];
        end
    end

endmodule