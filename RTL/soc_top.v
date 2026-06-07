`timescale 1ns/1ps
`include "defines.vh"

module soc_top #(
    parameter integer CLKS_PER_BIT = 868
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        uart_rxd,
    output wire        uart_txd,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu,
    output wire        debug_cpu_run
);

    wire rst;
    assign rst = ~rst_n;

    wire [7:0] rx_char;
    wire       rx_valid;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_rx (
        .clk        (clk),
        .rst        (rst),
        .rx         (uart_rxd),
        .data_out   (rx_char),
        .data_valid (rx_valid)
    );

    wire [31:0] instruction_word;
    wire        instruction_valid;

    hex_parser u_hex_parser (
        .clk               (clk),
        .rst               (rst),
        .ascii_char        (rx_char),
        .ascii_valid       (rx_valid),
        .instruction_word  (instruction_word),
        .instruction_valid (instruction_valid)
    );

    wire        load_we;
    wire [7:0]  load_addr;
    wire [31:0] load_data;
    wire        cpu_run;
    wire        cpu_reset_mon;
    wire        loaded_pulse;
    wire        run_pulse;

    program_loader u_loader (
        .clk               (clk),
        .rst               (rst),
        .ascii_char        (rx_char),
        .ascii_valid       (rx_valid),
        .instruction_word  (instruction_word),
        .instruction_valid (instruction_valid),
        .load_we           (load_we),
        .load_addr         (load_addr),
        .load_data         (load_data),
        .cpu_run           (cpu_run),
        .cpu_reset         (cpu_reset_mon),
        .loaded_pulse      (loaded_pulse),
        .run_pulse         (run_pulse)
    );

    assign debug_cpu_run = cpu_run;

    wire cpu_rst;
    assign cpu_rst = rst | cpu_reset_mon | (~cpu_run);

    wire cpu_en;
    assign cpu_en = cpu_run;

    wire [7:0] cpu_uart_tx_data;
    wire       cpu_uart_tx_valid;
    wire       tx_busy;

    cpu_top u_cpu (
        .clk                (clk),
        .rst                (cpu_rst),
        .cpu_en             (cpu_en),

        .load_we            (load_we),
        .load_addr          (load_addr),
        .load_data          (load_data),

        .cpu_uart_tx_data   (cpu_uart_tx_data),
        .cpu_uart_tx_valid  (cpu_uart_tx_valid),
        .cpu_uart_tx_busy   (tx_busy),

        .debug_pc           (debug_pc),
        .debug_instr        (debug_instr),
        .debug_alu_result   (debug_alu)
    );

    reg  [7:0] tx_data;
    reg        tx_start;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_tx (
        .clk       (clk),
        .rst       (rst),
        .data_in   (tx_data),
        .tx_start  (tx_start),
        .tx        (uart_txd),
        .tx_busy   (tx_busy)
    );

    localparam TX_IDLE = 2'd0;
    localparam TX_CPU  = 2'd1;
    localparam TX_LOAD = 2'd2;
    localparam TX_RUN  = 2'd3;

    reg [1:0] tx_state;
    reg [3:0] tx_index;
    reg       tx_busy_d;

    wire tx_done;
    assign tx_done = tx_busy_d & ~tx_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_state  <= TX_IDLE;
            tx_index  <= 4'd0;
            tx_data   <= 8'h00;
            tx_start  <= 1'b0;
            tx_busy_d <= 1'b0;
        end else begin
            tx_start  <= 1'b0;
            tx_busy_d <= tx_busy;

            case (tx_state)

                TX_IDLE: begin
                    tx_index <= 4'd0;

                    if (cpu_uart_tx_valid)
                        tx_state <= TX_CPU;
                    else if (loaded_pulse)
                        tx_state <= TX_LOAD;
                    else if (run_pulse)
                        tx_state <= TX_RUN;
                end

                TX_CPU: begin
                    if (!tx_busy && !tx_start) begin
                        tx_data  <= cpu_uart_tx_data;
                        tx_start <= 1'b1;
                    end

                    if (tx_done)
                        tx_state <= TX_IDLE;
                end

                TX_LOAD: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            4'd0: tx_data <= "L";
                            4'd1: tx_data <= "O";
                            4'd2: tx_data <= "A";
                            4'd3: tx_data <= "D";
                            4'd4: tx_data <= 8'h0D;
                            4'd5: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase
                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 4'd5) begin
                            tx_index <= 4'd0;
                            tx_state <= TX_IDLE;
                        end else begin
                            tx_index <= tx_index + 1'b1;
                        end
                    end
                end

                TX_RUN: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            4'd0: tx_data <= "R";
                            4'd1: tx_data <= "U";
                            4'd2: tx_data <= "N";
                            4'd3: tx_data <= 8'h0D;
                            4'd4: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase
                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 4'd4) begin
                            tx_index <= 4'd0;
                            tx_state <= TX_IDLE;
                        end else begin
                            tx_index <= tx_index + 1'b1;
                        end
                    end
                end

                default: begin
                    tx_state <= TX_IDLE;
                end

            endcase
        end
    end

endmodule