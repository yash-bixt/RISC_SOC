`timescale 1ns/1ps
`include "defines.vh"

module cpu_top_tb;

reg clk;
reg rst;

wire [31:0] debug_pc;
wire [31:0] debug_instr;
wire [31:0] debug_alu_result;

cpu_top #(
    .IMEM_INIT_FILE("D:/Vivado_Projects/RISC_SOC_v2/program.dat")
) dut (
    .clk(clk),
    .rst(rst),
    .debug_pc(debug_pc),
    .debug_instr(debug_instr),
    .debug_alu_result(debug_alu_result)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    #20;
    rst = 0;

    #300;
    $finish;
end

initial begin
    $monitor("T=%0t | PC=%h | INSTR=%h | ALU=%h",
             $time, debug_pc, debug_instr, debug_alu_result);
end

endmodule