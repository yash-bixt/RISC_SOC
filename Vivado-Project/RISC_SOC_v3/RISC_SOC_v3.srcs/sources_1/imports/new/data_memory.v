`timescale 1ns/1ps
`include "defines.vh"

module data_memory #(
    parameter DEPTH = 256
)(
    input  wire                         clk,
    input  wire                         mem_read,
    input  wire                         mem_write,

    input  wire [`ADDR_WIDTH-1:0]       addr,
    input  wire [`DATA_WIDTH-1:0]       write_data,

    output wire [`DATA_WIDTH-1:0]       read_data
);

    // --------------------------------------------------------
    // Data Memory Array
    // --------------------------------------------------------

    reg [`DATA_WIDTH-1:0] dmem [0:DEPTH-1];

    wire [7:0] word_addr;

    integer i;

    // --------------------------------------------------------
    // Word-Aligned Addressing
    // --------------------------------------------------------

    assign word_addr = addr[9:2];

    // --------------------------------------------------------
    // Memory Initialization
    // --------------------------------------------------------

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            dmem[i] = 32'd0;
    end

    // --------------------------------------------------------
    // Synchronous Write
    // --------------------------------------------------------

    always @(posedge clk) begin
        if (mem_write)
            dmem[word_addr] <= write_data;
    end

    // --------------------------------------------------------
    // Asynchronous Read
    // --------------------------------------------------------

    assign read_data = mem_read ? dmem[word_addr] : 32'd0;

endmodule