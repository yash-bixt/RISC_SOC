`timescale 1ns/1ps

module seg7_driver (
    input  wire        clk_100mhz,
    input  wire        rst,

    input  wire [31:0] pc_val,
    input  wire [31:0] alu_val,
    input  wire [31:0] instr_val,

    input  wire [1:0]  display_sel,

    output reg  [7:0]  seg_an,
    output reg  [7:0]  seg_cat
);

    // --------------------------------------------------------
    // Display Scan Counter
    // --------------------------------------------------------

    reg [16:0] scan_cnt;

    always @(posedge clk_100mhz or posedge rst) begin
        if (rst)
            scan_cnt <= 17'd0;
        else
            scan_cnt <= scan_cnt + 17'd1;
    end

    wire [2:0] digit_sel;

    assign digit_sel = scan_cnt[16:14];

    // --------------------------------------------------------
    // Display Value Selection
    // --------------------------------------------------------

    reg [31:0] display_val;

    always @(*) begin
        case (display_sel)
            2'b00:   display_val = pc_val;
            2'b01:   display_val = alu_val;
            2'b10:   display_val = instr_val;
            2'b11:   display_val = {pc_val[15:0], alu_val[15:0]};
            default: display_val = 32'd0;
        endcase
    end

    // --------------------------------------------------------
    // Nibble Selection
    // digit_sel = 0 selects rightmost digit
    // --------------------------------------------------------

    reg [3:0] nibble;

    always @(*) begin
        case (digit_sel)
            3'd0:    nibble = display_val[3:0];
            3'd1:    nibble = display_val[7:4];
            3'd2:    nibble = display_val[11:8];
            3'd3:    nibble = display_val[15:12];
            3'd4:    nibble = display_val[19:16];
            3'd5:    nibble = display_val[23:20];
            3'd6:    nibble = display_val[27:24];
            3'd7:    nibble = display_val[31:28];
            default: nibble = 4'h0;
        endcase
    end

    // --------------------------------------------------------
    // Anode Selection
    // Active LOW anodes
    // --------------------------------------------------------

    always @(*) begin
        seg_an            = 8'hFF;
        seg_an[digit_sel] = 1'b0;
    end

    // --------------------------------------------------------
    // Hex to 7-Segment Decoder
    // Active LOW cathodes
    // Segment order: CA CB CC CD CE CF CG DP
    // --------------------------------------------------------

    always @(*) begin
        case (nibble)
            4'h0:    seg_cat = 8'b0000001_1;
            4'h1:    seg_cat = 8'b1001111_1;
            4'h2:    seg_cat = 8'b0010010_1;
            4'h3:    seg_cat = 8'b0000110_1;

            4'h4:    seg_cat = 8'b1001100_1;
            4'h5:    seg_cat = 8'b0100100_1;
            4'h6:    seg_cat = 8'b0100000_1;
            4'h7:    seg_cat = 8'b0001111_1;

            4'h8:    seg_cat = 8'b0000000_1;
            4'h9:    seg_cat = 8'b0000100_1;
            4'hA:    seg_cat = 8'b0001000_1;
            4'hB:    seg_cat = 8'b1100000_1;

            4'hC:    seg_cat = 8'b0110001_1;
            4'hD:    seg_cat = 8'b1000010_1;
            4'hE:    seg_cat = 8'b0110000_1;
            4'hF:    seg_cat = 8'b0111000_1;

            default: seg_cat = 8'b1111111_1;
        endcase
    end

endmodule