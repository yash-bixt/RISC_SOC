`timescale 1ns/1ps

module tb_soc_top;

    reg clk;
    reg rst_n;
    reg uart_rxd;

    wire uart_txd;
    wire [31:0] debug_pc;
    wire [31:0] debug_instr;
    wire [31:0] debug_alu;
    wire        debug_cpu_run;

    localparam integer CLK_PERIOD   = 10;
    localparam integer CLKS_PER_BIT = 868;
    localparam integer BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    soc_top #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .uart_rxd      (uart_rxd),
        .uart_txd      (uart_txd),
        .debug_pc      (debug_pc),
        .debug_instr   (debug_instr),
        .debug_alu     (debug_alu),
        .debug_cpu_run (debug_cpu_run)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            uart_rxd = 1'b0;
            #(BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                uart_rxd = data[i];
                #(BIT_PERIOD);
            end

            uart_rxd = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    task uart_send_string;
        input [8*64-1:0] str;
        integer i;
        reg [7:0] ch;
        begin
            for (i = 63; i >= 0; i = i - 1) begin
                ch = str[i*8 +: 8];
                if (ch != 8'h00) begin
                    uart_send_byte(ch);
                end
            end
        end
    endtask

    initial begin
        $dumpfile("waves/tb_soc_top.vcd");
        $dumpvars(0, tb_soc_top);

        uart_rxd = 1'b1;
        rst_n    = 1'b0;

        #(20 * CLK_PERIOD);
        rst_n = 1'b1;

        #(20 * CLK_PERIOD);

        // Example program:
        // ADDI r1, r0, 5
        // ADDI r2, r0, 3
        // ADD  r3, r1, r2
        // HALT
        //
        // Replace these hex values with your assembler output if needed.

        uart_send_string("04010005");
        uart_send_byte(8'h0D);
        uart_send_byte(8'h0A);

        uart_send_string("04020003");
        uart_send_byte(8'h0D);
        uart_send_byte(8'h0A);

        uart_send_string("00221800");
        uart_send_byte(8'h0D);
        uart_send_byte(8'h0A);

        uart_send_string("F8000000");
        uart_send_byte(8'h0D);
        uart_send_byte(8'h0A);

        uart_send_string("RUN");
        uart_send_byte(8'h0D);
        uart_send_byte(8'h0A);

        repeat (2000) begin
            @(posedge clk);
            $display("TIME=%0t RUN=%b PC=%h INSTR=%h ALU=%h",
                     $time, debug_cpu_run, debug_pc, debug_instr, debug_alu);
        end

        $finish;
    end

endmodule