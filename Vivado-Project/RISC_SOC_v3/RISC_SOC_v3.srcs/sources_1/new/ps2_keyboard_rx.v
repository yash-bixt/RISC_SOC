`timescale 1ns/1ps

module ps2_keyboard_rx (
    input  wire clk,
    input  wire rst,

    input  wire ps2_clk,
    input  wire ps2_data,

    output reg  [7:0] scan_code,
    output reg        scan_valid
);

    reg [2:0] ps2_clk_sync;
    reg [10:0] shift_reg;
    reg [3:0] bit_count;

    wire ps2_clk_falling;

    always @(posedge clk) begin
        ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
    end

    assign ps2_clk_falling = (ps2_clk_sync[2:1] == 2'b10);

    always @(posedge clk) begin
        if (rst) begin
            shift_reg  <= 11'd0;
            bit_count  <= 4'd0;
            scan_code  <= 8'd0;
            scan_valid <= 1'b0;
        end
        else begin
            scan_valid <= 1'b0;

            if (ps2_clk_falling) begin
                shift_reg <= {ps2_data, shift_reg[10:1]};

                if (bit_count == 4'd10) begin
                    scan_code  <= shift_reg[8:1];
                    scan_valid <= 1'b1;
                    bit_count  <= 4'd0;
                end
                else begin
                    bit_count <= bit_count + 4'd1;
                end
            end
        end
    end

endmodule