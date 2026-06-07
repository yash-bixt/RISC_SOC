`timescale 1ns/1ps

module uart_status (
    input  wire        clk,
    input  wire        rst,

    input  wire        uart_rx_valid,
    input  wire        uart_tx_busy,
    input  wire        instr_valid,
    input  wire        load_done,
    input  wire        cpu_running,
    input  wire        error_flag,

    input  wire [31:0] debug_pc,
    input  wire [31:0] debug_instr,
    input  wire [31:0] debug_alu,

    output reg  [15:0] led
);

    reg [23:0] rx_blink_cnt;
    reg [23:0] instr_blink_cnt;
    reg [23:0] load_blink_cnt;

    wire rx_blink_on    = (rx_blink_cnt    != 24'd0);
    wire instr_blink_on = (instr_blink_cnt != 24'd0);
    wire load_blink_on  = (load_blink_cnt  != 24'd0);

    always @(posedge clk) begin
        if (rst) begin
            rx_blink_cnt    <= 24'd0;
            instr_blink_cnt <= 24'd0;
            load_blink_cnt  <= 24'd0;
        end else begin
            if (uart_rx_valid)
                rx_blink_cnt <= 24'd5_000_000;
            else if (rx_blink_cnt != 24'd0)
                rx_blink_cnt <= rx_blink_cnt - 1'b1;

            if (instr_valid)
                instr_blink_cnt <= 24'd5_000_000;
            else if (instr_blink_cnt != 24'd0)
                instr_blink_cnt <= instr_blink_cnt - 1'b1;

            if (load_done)
                load_blink_cnt <= 24'd5_000_000;
            else if (load_blink_cnt != 24'd0)
                load_blink_cnt <= load_blink_cnt - 1'b1;
        end
    end

    always @(*) begin
        led = 16'b0;

        led[0]  = rx_blink_on;
        led[1]  = uart_tx_busy;
        led[2]  = instr_blink_on;
        led[3]  = load_blink_on;
        led[4]  = cpu_running;
        led[5]  = error_flag;

        led[7:6]   = debug_pc[3:2];
        led[11:8]  = debug_instr[3:0];
        led[15:12] = debug_alu[3:0];
    end

endmodule