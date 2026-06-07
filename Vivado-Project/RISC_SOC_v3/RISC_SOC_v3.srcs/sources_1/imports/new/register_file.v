`timescale 1ns/1ps
`include "defines.vh"

module register_file (
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         reg_write,

    input  wire [`REG_ADDR_W-1:0]      rs1,
    input  wire [`REG_ADDR_W-1:0]      rs2,
    input  wire [`REG_ADDR_W-1:0]      rd,

    input  wire [`DATA_WIDTH-1:0]      write_data,

    output wire [`DATA_WIDTH-1:0]      read_data1,
    output wire [`DATA_WIDTH-1:0]      read_data2
);

    // --------------------------------------------------------
    // Register File Storage
    // --------------------------------------------------------

    reg [`DATA_WIDTH-1:0] registers [0:`REG_COUNT-1];

    integer i;

    // --------------------------------------------------------
    // Synchronous Write + Reset
    // --------------------------------------------------------

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `REG_COUNT; i = i + 1)
                registers[i] <= 32'd0;
        end
        else if (reg_write && (rd != 0)) begin
            registers[rd] <= write_data;
        end
    end

    // --------------------------------------------------------
    // Asynchronous Read Ports
    // --------------------------------------------------------

    assign read_data1 = (rs1 == 0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 0) ? 32'd0 : registers[rs2];

endmodule