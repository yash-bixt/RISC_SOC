`timescale 1ns/1ps
`include "defines.vh"

module alu_tb;

reg  [31:0] a, b;
reg  [3:0]  alu_op;
wire [31:0] result;
wire        zero;

alu dut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .result(result),
    .zero(zero)
);

initial begin
    a = 32'h0000AAAA;
    b = 32'h00005555;

    alu_op = `ALU_ADD; #10;
    alu_op = `ALU_SUB; #10;
    alu_op = `ALU_AND; #10;
    alu_op = `ALU_OR;  #10;
    alu_op = `ALU_XOR; #10;

    a = 32'd5;
    b = 32'd5;
    alu_op = `ALU_SUB; #10;

    $finish;
end

endmodule