`timescale 1ns/1ps

module nexys4_top_tb;

reg CLK100MHZ;
reg CPU_RESETN;
reg [15:0] SW;
reg BTNC;

wire [15:0] LED;
wire [7:0] AN;
wire CA, CB, CC, CD, CE, CF, CG, DP;

nexys4_top dut (
    .CLK100MHZ(CLK100MHZ),
    .CPU_RESETN(CPU_RESETN),
    .SW(SW),
    .BTNC(BTNC),
    .LED(LED),
    .AN(AN),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG),
    .DP(DP)
);

initial begin
    CLK100MHZ = 0;
    forever #5 CLK100MHZ = ~CLK100MHZ;
end

initial begin
    SW = 16'd0;
    BTNC = 1'b0;

    CPU_RESETN = 1'b0;
    #100;
    CPU_RESETN = 1'b1;

    // slow mode, PC display
    SW[15] = 1'b1;      // use fast mode in simulation
    SW[14:13] = 2'b00;  // PC

    #1000;

    SW[14:13] = 2'b01;  // ALU
    #1000;

    SW[14:13] = 2'b10;  // Instruction
    #1000;

    SW[14:13] = 2'b11;  // PC | ALU
    #1000;

    $finish;
end

endmodule