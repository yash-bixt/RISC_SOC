`timescale 1ns/1ps
`include "defines.vh"

module pc (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   en,
    input  wire [`ADDR_WIDTH-1:0] next_pc,
    output reg  [`ADDR_WIDTH-1:0] pc_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= {`ADDR_WIDTH{1'b0}};
        end else if (en) begin
            pc_out <= next_pc;
        end
    end

endmodule