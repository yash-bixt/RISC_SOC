`timescale 1ns/1ps

module uart_tx #(
    parameter integer CLKS_PER_BIT = 868,
    parameter integer CLK_CNT_WIDTH = 16
)(
    input  wire      clk,
    input  wire      rst,
    input  wire [7:0] data_in,
    input  wire      tx_start,
    output reg       tx,
    output reg       tx_busy
);

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;
    localparam CLEAN = 3'd4;

    reg [2:0] state;
    reg [CLK_CNT_WIDTH-1:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_shift;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= {CLK_CNT_WIDTH{1'b0}};
            bit_index <= 3'd0;
            tx_shift  <= 8'd0;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    clk_count <= {CLK_CNT_WIDTH{1'b0}};
                    bit_index <= 3'd0;

                    if (tx_start) begin
                        tx_shift <= data_in;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= {CLK_CNT_WIDTH{1'b0}};
                        state     <= DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    tx <= tx_shift[bit_index];

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= {CLK_CNT_WIDTH{1'b0}};

                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= {CLK_CNT_WIDTH{1'b0}};
                        state     <= CLEAN;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                CLEAN: begin
                    tx_busy <= 1'b0;
                    state   <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule