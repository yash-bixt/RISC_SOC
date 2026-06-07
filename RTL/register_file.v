`timescale 1ns/1ps
`include "defines.vh"

module register_file (
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         reg_write,

    input  wire [`REG_ADDR_W-1:0]       rs1,
    input  wire [`REG_ADDR_W-1:0]       rs2,
    input  wire [`REG_ADDR_W-1:0]       rd,

    input  wire [`DATA_WIDTH-1:0]       write_data,

    output wire [`DATA_WIDTH-1:0]       read_data1,
    output wire [`DATA_WIDTH-1:0]       read_data2
);

    reg [`DATA_WIDTH-1:0] registers [0:`REG_COUNT-1];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `REG_COUNT; i = i + 1) begin
                registers[i] <= {`DATA_WIDTH{1'b0}};
            end
        end else begin
            if (reg_write && (rd != {`REG_ADDR_W{1'b0}})) begin
                registers[rd] <= write_data;
            end
        end
    end

    assign read_data1 = (rs1 == {`REG_ADDR_W{1'b0}}) ? {`DATA_WIDTH{1'b0}} : registers[rs1];
    assign read_data2 = (rs2 == {`REG_ADDR_W{1'b0}}) ? {`DATA_WIDTH{1'b0}} : registers[rs2];

endmodule