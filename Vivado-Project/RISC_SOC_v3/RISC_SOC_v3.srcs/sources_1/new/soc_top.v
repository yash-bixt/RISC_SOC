`timescale 1ns/1ps
`include "defines.vh"

module soc_top #(
    parameter integer CLKS_PER_BIT = 868
)(
    input  wire        clk,
    input  wire        rst,

    input  wire        uart_rxd,
    output wire        uart_txd,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu,
    output wire [7:0]  debug_rx_char,
    output wire        debug_cpu_run,
    output wire [15:0] status_led
);

    function [7:0] hex_ascii;
        input [3:0] nibble;
        begin
            hex_ascii = (nibble < 4'd10) ? ("0" + nibble) : ("A" + nibble - 4'd10);
        end
    endfunction

    wire [7:0] rx_char;
    wire       rx_valid;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart_rx (
        .clk(clk),
        .rst(rst),
        .rx(uart_rxd),
        .data_out(rx_char),
        .data_valid(rx_valid)
    );

    assign debug_rx_char = rx_char;

    wire [31:0] instruction_word;
    wire        instruction_valid;

    hex_parser u_hex_parser (
        .clk(clk),
        .rst(rst),
        .ascii_char(rx_char),
        .ascii_valid(rx_valid),
        .instruction_word(instruction_word),
        .instruction_valid(instruction_valid)
    );

    wire        load_we;
    wire [7:0]  load_addr;
    wire [31:0] load_data;
    wire        cpu_run;
    wire        cpu_reset_mon;
    wire        loaded_pulse;
    wire        run_pulse;

    program_loader u_loader (
        .clk(clk),
        .rst(rst),
        .ascii_char(rx_char),
        .ascii_valid(rx_valid),
        .instruction_word(instruction_word),
        .instruction_valid(instruction_valid),
        .load_we(load_we),
        .load_addr(load_addr),
        .load_data(load_data),
        .cpu_run(cpu_run),
        .cpu_reset(cpu_reset_mon),
        .loaded_pulse(loaded_pulse),
        .run_pulse(run_pulse)
    );

    assign debug_cpu_run = cpu_run;

    wire cpu_rst = rst | cpu_reset_mon | (~cpu_run);

    reg [25:0] cpu_step_cnt;
    reg        cpu_en;

    always @(posedge clk) begin
        if (cpu_rst) begin
            cpu_step_cnt <= 26'd0;
            cpu_en       <= 1'b0;
        end else begin
            if (cpu_step_cnt == 26'd50_000_000) begin
                cpu_step_cnt <= 26'd0;
                cpu_en       <= 1'b1;
            end else begin
                cpu_step_cnt <= cpu_step_cnt + 1'b1;
                cpu_en       <= 1'b0;
            end
        end
    end

    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    wire [31:0] cpu_debug_pc;
    wire [31:0] cpu_debug_instr;
    wire [31:0] cpu_debug_alu;
    wire [7:0]  cpu_uart_tx_data;
    wire        cpu_uart_tx_valid;

    cpu_top u_cpu (
        .clk(clk),
        .rst(cpu_rst),
        .cpu_en(cpu_en),

        .load_we(load_we),
        .load_addr(load_addr),
        .load_data(load_data),

        .cpu_uart_tx_data(cpu_uart_tx_data),
        .cpu_uart_tx_valid(cpu_uart_tx_valid),
        .cpu_uart_tx_busy(tx_busy),

        .debug_pc(cpu_debug_pc),
        .debug_instr(cpu_debug_instr),
        .debug_alu_result(cpu_debug_alu)
    );

    assign debug_pc = cpu_debug_pc;

    reg [31:0] last_loaded_instr;
    reg [31:0] last_exec_alu;

    always @(posedge clk) begin
        if (rst)
            last_loaded_instr <= 32'h00000000;
        else if (instruction_valid)
            last_loaded_instr <= instruction_word;
    end

    always @(posedge clk) begin
        if (cpu_rst) begin
            last_exec_alu <= 32'd0;
        end else if (cpu_en && cpu_debug_instr[31:26] != `OP_HALT) begin
            last_exec_alu <= cpu_debug_alu;
        end
    end

    assign debug_instr = cpu_run ? cpu_debug_instr : last_loaded_instr;
    assign debug_alu   = last_exec_alu;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart_tx (
        .clk(clk),
        .rst(rst),
        .data_in(tx_data),
        .tx_start(tx_start),
        .tx(uart_txd),
        .tx_busy(tx_busy)
    );

    reg [31:0] trace_pc;
    reg [31:0] trace_instr;
    reg [31:0] trace_alu;
    reg        trace_pending;
    reg        trace_halted;
    reg        trace_clear;

    always @(posedge clk) begin
        if (cpu_rst) begin
            trace_pc      <= 32'd0;
            trace_instr   <= 32'd0;
            trace_alu     <= 32'd0;
            trace_pending <= 1'b0;
            trace_halted  <= 1'b0;
        end else begin
            if (trace_clear) begin
                trace_pending <= 1'b0;
            end else if (cpu_en && !trace_halted && !trace_pending) begin
                trace_pc      <= cpu_debug_pc;
                trace_instr   <= cpu_debug_instr;

                if (cpu_debug_instr[31:26] == `OP_HALT)
                    trace_alu <= last_exec_alu;
                else
                    trace_alu <= cpu_debug_alu;

                trace_pending <= 1'b1;

                if (cpu_debug_instr[31:26] == `OP_HALT)
                    trace_halted <= 1'b1;
            end
        end
    end

    localparam TX_IDLE  = 4'd0;
    localparam TX_READY = 4'd1;
    localparam TX_LOAD  = 4'd2;
    localparam TX_RUN   = 4'd3;
    localparam TX_CPU   = 4'd4;
    localparam TX_TRACE = 4'd5;

    reg [3:0] tx_state;
    reg [5:0] tx_index;
    reg       ready_sent;
    reg       tx_busy_d;

    wire tx_done = tx_busy_d & ~tx_busy;

    always @(posedge clk) begin
        if (rst) begin
            tx_state    <= TX_READY;
            tx_index    <= 6'd0;
            ready_sent  <= 1'b0;
            tx_data     <= 8'h00;
            tx_start    <= 1'b0;
            tx_busy_d   <= 1'b0;
            trace_clear <= 1'b0;
        end else begin
            tx_start    <= 1'b0;
            tx_busy_d   <= tx_busy;
            trace_clear <= 1'b0;

            case (tx_state)

                TX_IDLE: begin
                    tx_index <= 6'd0;

                    if (trace_pending)
                        tx_state <= TX_TRACE;
                    else if (cpu_uart_tx_valid)
                        tx_state <= TX_CPU;
                    else if (!ready_sent)
                        tx_state <= TX_READY;
                    else if (run_pulse)
                        tx_state <= TX_RUN;
                    else if (loaded_pulse)
                        tx_state <= TX_LOAD;
                end

                TX_CPU: begin
                    if (!tx_busy && !tx_start) begin
                        tx_data  <= cpu_uart_tx_data;
                        tx_start <= 1'b1;
                    end

                    if (tx_done)
                        tx_state <= TX_IDLE;
                end

                TX_READY: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            6'd0: tx_data <= "R";
                            6'd1: tx_data <= "E";
                            6'd2: tx_data <= "A";
                            6'd3: tx_data <= "D";
                            6'd4: tx_data <= "Y";
                            6'd5: tx_data <= " ";
                            6'd6: tx_data <= ">";
                            6'd7: tx_data <= 8'h0D;
                            6'd8: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase
                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 6'd8) begin
                            ready_sent <= 1'b1;
                            tx_index   <= 6'd0;
                            tx_state   <= TX_IDLE;
                        end else begin
                            tx_index <= tx_index + 1'b1;
                        end
                    end
                end

                TX_LOAD: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            6'd0: tx_data <= "L";
                            6'd1: tx_data <= "O";
                            6'd2: tx_data <= "A";
                            6'd3: tx_data <= "D";
                            6'd4: tx_data <= "E";
                            6'd5: tx_data <= "D";
                            6'd6: tx_data <= 8'h0D;
                            6'd7: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase
                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 6'd7) begin
                            tx_index <= 6'd0;
                            tx_state <= TX_IDLE;
                        end else begin
                            tx_index <= tx_index + 1'b1;
                        end
                    end
                end

                TX_RUN: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            6'd0: tx_data <= "R";
                            6'd1: tx_data <= "U";
                            6'd2: tx_data <= "N";
                            6'd3: tx_data <= 8'h0D;
                            6'd4: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase
                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 6'd4) begin
                            tx_index <= 6'd0;
                            tx_state <= TX_IDLE;
                        end else begin
                            tx_index <= tx_index + 1'b1;
                        end
                    end
                end

                TX_TRACE: begin
                    if (!tx_busy && !tx_start) begin
                        case (tx_index)
                            6'd0:  tx_data <= "P";
                            6'd1:  tx_data <= "C";
                            6'd2:  tx_data <= "=";
                            6'd3:  tx_data <= hex_ascii(trace_pc[31:28]);
                            6'd4:  tx_data <= hex_ascii(trace_pc[27:24]);
                            6'd5:  tx_data <= hex_ascii(trace_pc[23:20]);
                            6'd6:  tx_data <= hex_ascii(trace_pc[19:16]);
                            6'd7:  tx_data <= hex_ascii(trace_pc[15:12]);
                            6'd8:  tx_data <= hex_ascii(trace_pc[11:8]);
                            6'd9:  tx_data <= hex_ascii(trace_pc[7:4]);
                            6'd10: tx_data <= hex_ascii(trace_pc[3:0]);

                            6'd11: tx_data <= " ";
                            6'd12: tx_data <= "A";
                            6'd13: tx_data <= "L";
                            6'd14: tx_data <= "U";
                            6'd15: tx_data <= "=";
                            6'd16: tx_data <= hex_ascii(trace_alu[31:28]);
                            6'd17: tx_data <= hex_ascii(trace_alu[27:24]);
                            6'd18: tx_data <= hex_ascii(trace_alu[23:20]);
                            6'd19: tx_data <= hex_ascii(trace_alu[19:16]);
                            6'd20: tx_data <= hex_ascii(trace_alu[15:12]);
                            6'd21: tx_data <= hex_ascii(trace_alu[11:8]);
                            6'd22: tx_data <= hex_ascii(trace_alu[7:4]);
                            6'd23: tx_data <= hex_ascii(trace_alu[3:0]);

                            6'd24: tx_data <= " ";
                            6'd25: tx_data <= "I";
                            6'd26: tx_data <= "N";
                            6'd27: tx_data <= "S";
                            6'd28: tx_data <= "T";
                            6'd29: tx_data <= "R";
                            6'd30: tx_data <= "=";
                            6'd31: tx_data <= hex_ascii(trace_instr[31:28]);
                            6'd32: tx_data <= hex_ascii(trace_instr[27:24]);
                            6'd33: tx_data <= hex_ascii(trace_instr[23:20]);
                            6'd34: tx_data <= hex_ascii(trace_instr[19:16]);
                            6'd35: tx_data <= hex_ascii(trace_instr[15:12]);
                            6'd36: tx_data <= hex_ascii(trace_instr[11:8]);
                            6'd37: tx_data <= hex_ascii(trace_instr[7:4]);
                            6'd38: tx_data <= hex_ascii(trace_instr[3:0]);

                            6'd39: tx_data <= 8'h0D;
                            6'd40: tx_data <= 8'h0A;
                            default: tx_data <= 8'h20;
                        endcase

                        tx_start <= 1'b1;
                    end

                    if (tx_done) begin
                        if (tx_index == 6'd40) begin
                            tx_index    <= 6'd0;
                            tx_state    <= TX_IDLE;
                            trace_clear <= 1'b1;
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

    uart_status u_uart_status (
        .clk(clk),
        .rst(rst),
        .uart_rx_valid(rx_valid),
        .uart_tx_busy(tx_busy),
        .instr_valid(instruction_valid),
        .load_done(loaded_pulse),
        .cpu_running(cpu_run),
        .error_flag(1'b0),
        .debug_pc(debug_pc),
        .debug_instr(debug_instr),
        .debug_alu(debug_alu),
        .led(status_led)
    );

endmodule