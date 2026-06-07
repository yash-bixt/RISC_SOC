`timescale 1ns/1ps
`include "defines.vh"

module data_memory #(
    parameter DEPTH = 256
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire                         mem_read,
    input  wire                         mem_write,

    input  wire [`ADDR_WIDTH-1:0]       addr,
    input  wire [`DATA_WIDTH-1:0]       write_data,

    output reg  [`DATA_WIDTH-1:0]       read_data
);

    reg [`DATA_WIDTH-1:0] dmem [0:DEPTH-1];

    wire [7:0] word_addr;
    assign word_addr = addr[9:2];

    always @(posedge clk) begin
        if (rst) begin
            read_data <= {`DATA_WIDTH{1'b0}};
        end else begin
            if (mem_write) begin
                dmem[word_addr] <= write_data;
            end

            if (mem_read) begin
                read_data <= dmem[word_addr];
            end else begin
                read_data <= {`DATA_WIDTH{1'b0}};
            end
        end
    end

endmodule