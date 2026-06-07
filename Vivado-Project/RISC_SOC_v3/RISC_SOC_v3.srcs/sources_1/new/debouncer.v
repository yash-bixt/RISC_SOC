`timescale 1ns / 1ps
// Debouncer - identical to the verified working keyboard demo.
// Filters PS2_CLK and PS2_DATA for 20 cycles (~400 ns at 50 MHz).

module debouncer(
    input  wire clk,   // 50 MHz
    input  wire I0,    // raw PS2_CLK
    input  wire I1,    // raw PS2_DATA
    output reg  O0,    // debounced PS2_CLK
    output reg  O1     // debounced PS2_DATA
);
    reg [4:0] cnt0 = 0, cnt1 = 0;
    reg Iv0 = 0, Iv1 = 0;

    always @(posedge clk) begin
        if (I0 == Iv0) begin
            if (cnt0 == 19) O0 <= I0;
            else            cnt0 <= cnt0 + 1;
        end else begin
            cnt0 <= 5'd0;
            Iv0  <= I0;
        end

        if (I1 == Iv1) begin
            if (cnt1 == 19) O1 <= I1;
            else            cnt1 <= cnt1 + 1;
        end else begin
            cnt1 <= 5'd0;
            Iv1  <= I1;
        end
    end
endmodule