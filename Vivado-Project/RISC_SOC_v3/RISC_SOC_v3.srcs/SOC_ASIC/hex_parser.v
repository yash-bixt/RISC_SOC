`timescale 1ns/1ps

module hex_parser (
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] ascii_char,
    input  wire       ascii_valid,

    output reg  [31:0] instruction_word,
    output reg         instruction_valid
);

    reg [2:0]  hex_count;
    reg [31:0] temp_word;
    reg [3:0]  nibble;
    reg        is_hex;

    always @(*) begin
        is_hex = 1'b1;
        nibble = 4'd0;

        if (ascii_char >= "0" && ascii_char <= "9")
            nibble = ascii_char - "0";
        else if (ascii_char >= "A" && ascii_char <= "F")
            nibble = ascii_char - "A" + 4'd10;
        else if (ascii_char >= "a" && ascii_char <= "f")
            nibble = ascii_char - "a" + 4'd10;
        else
            is_hex = 1'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            hex_count         <= 3'd0;
            temp_word         <= 32'd0;
            instruction_word  <= 32'd0;
            instruction_valid <= 1'b0;
        end else begin
            instruction_valid <= 1'b0;

            if (ascii_valid && is_hex) begin
                if (hex_count == 3'd7) begin
                    instruction_word  <= {temp_word[27:0], nibble};
                    instruction_valid <= 1'b1;
                    hex_count         <= 3'd0;
                    temp_word         <= 32'd0;
                end else begin
                    temp_word <= {temp_word[27:0], nibble};
                    hex_count <= hex_count + 3'd1;
                end
            end

            // newline, carriage return or space cancels incomplete hex word
            if (ascii_valid && (ascii_char == 8'h0D || ascii_char == 8'h0A || ascii_char == 8'h20)) begin
                hex_count <= 3'd0;
                temp_word <= 32'd0;
            end
        end
    end

endmodule
