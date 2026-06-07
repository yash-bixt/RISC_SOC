`timescale 1ns/1ps
`include "defines.vh"

module tb_soc_top_selfcheck;

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

    integer pass_count;
    integer fail_count;

    reg [31:0] prog [0:31];

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

    function [31:0] make_r;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        input [3:0] funct;
        begin
            make_r = {`OP_RTYPE, rs1, rs2, rd, 7'd0, funct};
        end
    endfunction

    function [31:0] make_i;
        input [5:0] opcode;
        input [4:0] rs1;
        input [4:0] rd_or_rs2;
        input [15:0] imm;
        begin
            make_i = {opcode, rs1, rd_or_rs2, imm};
        end
    endfunction

    function [31:0] make_j;
        input [25:0] addr;
        begin
            make_j = {`OP_J, addr};
        end
    endfunction

    function [7:0] hex_ascii;
        input [3:0] nibble;
        begin
            if (nibble < 10)
                hex_ascii = "0" + nibble;
            else
                hex_ascii = "A" + nibble - 10;
        end
    endfunction

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

    task send_hex32;
        input [31:0] word;
        begin
            uart_send_byte(hex_ascii(word[31:28]));
            uart_send_byte(hex_ascii(word[27:24]));
            uart_send_byte(hex_ascii(word[23:20]));
            uart_send_byte(hex_ascii(word[19:16]));
            uart_send_byte(hex_ascii(word[15:12]));
            uart_send_byte(hex_ascii(word[11:8]));
            uart_send_byte(hex_ascii(word[7:4]));
            uart_send_byte(hex_ascii(word[3:0]));
            uart_send_byte(8'h0D);
            uart_send_byte(8'h0A);
        end
    endtask

    task send_run;
        begin
            uart_send_byte("R");
            uart_send_byte("U");
            uart_send_byte("N");
            uart_send_byte(8'h0D);
            uart_send_byte(8'h0A);
        end
    endtask

    task reset_soc;
        begin
            uart_rxd = 1'b1;
            rst_n = 1'b0;
            repeat (20) @(posedge clk);
            rst_n = 1'b1;
            repeat (20) @(posedge clk);
        end
    endtask

    task upload_program;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                send_hex32(prog[i]);
            end
        end
    endtask

    task run_test;
        input [8*40-1:0] test_name;
        input integer instr_count;
        input [31:0] expected_alu;
        integer i;
        begin
            reset_soc();
            upload_program(instr_count);
            send_run();

            repeat (300) @(posedge clk);

            if (debug_alu === expected_alu) begin
                $display("[PASS] %s Expected=%h Got=%h PC=%h INSTR=%h",
                         test_name, expected_alu, debug_alu, debug_pc, debug_instr);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s Expected=%h Got=%h PC=%h INSTR=%h",
                         test_name, expected_alu, debug_alu, debug_pc, debug_instr);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_soc_top_selfcheck.vcd");
        $dumpvars(0, tb_soc_top_selfcheck);

        pass_count = 0;
        fail_count = 0;

        // ---------------- ADD ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd5);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd3);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_ADD);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("ADD 5+3", 4, 32'd8);

        // ---------------- SUB ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd10);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd3);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_SUB);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("SUB 10-3", 4, 32'd7);

        // ---------------- AND ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'h000F);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'h0003);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_AND);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("AND", 4, 32'h00000003);

        // ---------------- OR ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'h000C);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'h0003);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_OR);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("OR", 4, 32'h0000000F);

        // ---------------- XOR ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'h000C);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'h0003);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_XOR);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("XOR", 4, 32'h0000000F);

        // ---------------- MUL ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd6);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd7);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_MUL);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("MUL 6x7", 4, 32'd42);

        // ---------------- SLL ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd1);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd4);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_SLL);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("SLL", 4, 32'h00000010);

        // ---------------- SRL ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd16);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd2);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_SRL);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("SRL", 4, 32'h00000004);

        // ---------------- SLT TRUE ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd3);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd9);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_SLT);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("SLT TRUE", 4, 32'h00000001);

        // ---------------- SLT FALSE ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd9);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd3);
        prog[2] = make_r(5'd1, 5'd2, 5'd3, `FUNCT_SLT);
        prog[3] = {`OP_HALT, 26'd0};
        run_test("SLT FALSE", 4, 32'h00000000);

        // ---------------- LUI ----------------
        prog[0] = make_i(`OP_LUI, 5'd0, 5'd1, 16'h1234);
        prog[1] = {`OP_HALT, 26'd0};
        run_test("LUI", 2, 32'h12340000);

        // ---------------- BEQ TAKEN ----------------
        // r1=5, r2=5, BEQ skips ADDI r3,1 and executes ADDI r3,9
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd5);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd5);
        prog[2] = make_i(`OP_BEQ,  5'd1, 5'd2, 16'd1);
        prog[3] = make_i(`OP_ADDI, 5'd0, 5'd3, 16'd1);
        prog[4] = make_i(`OP_ADDI, 5'd0, 5'd3, 16'd9);
        prog[5] = {`OP_HALT, 26'd0};
        run_test("BEQ TAKEN", 6, 32'd9);

        // ---------------- BNE TAKEN ----------------
        prog[0] = make_i(`OP_ADDI, 5'd0, 5'd1, 16'd5);
        prog[1] = make_i(`OP_ADDI, 5'd0, 5'd2, 16'd8);
        prog[2] = make_i(`OP_BNE,  5'd1, 5'd2, 16'd1);
        prog[3] = make_i(`OP_ADDI, 5'd0, 5'd3, 16'd1);
        prog[4] = make_i(`OP_ADDI, 5'd0, 5'd3, 16'd11);
        prog[5] = {`OP_HALT, 26'd0};
        run_test("BNE TAKEN", 6, 32'd11);

        $display("=================================");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("=================================");

        $finish;
    end

endmodule