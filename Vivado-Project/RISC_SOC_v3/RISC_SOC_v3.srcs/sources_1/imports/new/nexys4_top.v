`timescale 1ns/1ps
`include "defines.vh"

module nexys4_top (
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,

    input  wire [15:0] SW,
    input  wire        BTNC,

    input  wire        UART_RXD,
    output wire        UART_TXD,

    output wire [15:0] LED,

    output wire [7:0]  AN,
    output wire        CA,
    output wire        CB,
    output wire        CC,
    output wire        CD,
    output wire        CE,
    output wire        CF,
    output wire        CG,
    output wire        DP
);

    wire rst_raw;
    wire rst_sync;

    wire [31:0] debug_pc;
    wire [31:0] debug_instr;
    wire [31:0] debug_alu;
    wire [7:0]  debug_rx_char;
    wire        debug_cpu_run;
    wire [15:0] status_led;

    wire [7:0] seg_an_n;
    wire [7:0] seg_cat_n;

    assign rst_raw = (~CPU_RESETN) | SW[0] | BTNC;

    reg rst_ff1;
    reg rst_ff2;

    always @(posedge CLK100MHZ or posedge rst_raw) begin
        if (rst_raw) begin
            rst_ff1 <= 1'b1;
            rst_ff2 <= 1'b1;
        end else begin
            rst_ff1 <= 1'b0;
            rst_ff2 <= rst_ff1;
        end
    end

    assign rst_sync = rst_ff2;

    soc_top #(
        .CLKS_PER_BIT(868)
    ) u_soc (
        .clk           (CLK100MHZ),
        .rst           (rst_sync),
        .uart_rxd      (UART_RXD),
        .uart_txd      (UART_TXD),
        .debug_pc      (debug_pc),
        .debug_instr   (debug_instr),
        .debug_alu     (debug_alu),
        .debug_rx_char (debug_rx_char),
        .debug_cpu_run (debug_cpu_run),
        .status_led    (status_led)
    );

    assign LED = status_led;

    seg7_driver u_seg7 (
        .clk_100mhz  (CLK100MHZ),
        .rst         (rst_sync),
        .pc_val      (debug_pc),
        .alu_val     (debug_alu),
        .instr_val   (debug_instr),
        .display_sel (SW[14:13]),
        .seg_an      (seg_an_n),
        .seg_cat     (seg_cat_n)
    );

    assign AN = seg_an_n;

    assign CA = seg_cat_n[7];
    assign CB = seg_cat_n[6];
    assign CC = seg_cat_n[5];
    assign CD = seg_cat_n[4];
    assign CE = seg_cat_n[3];
    assign CF = seg_cat_n[2];
    assign CG = seg_cat_n[1];
    assign DP = seg_cat_n[0];

endmodule