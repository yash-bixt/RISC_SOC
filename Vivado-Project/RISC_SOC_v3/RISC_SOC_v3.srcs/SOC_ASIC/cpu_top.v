`timescale 1ns/1ps
`include "defines.vh"

module cpu_top (
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         cpu_en,

    input  wire                         load_we,
    input  wire [7:0]                   load_addr,
    input  wire [`INSTR_WIDTH-1:0]      load_data,

    output wire [7:0]                   cpu_uart_tx_data,
    output wire                         cpu_uart_tx_valid,
    input  wire                         cpu_uart_tx_busy,

    output wire [`ADDR_WIDTH-1:0]       debug_pc,
    output wire [`INSTR_WIDTH-1:0]      debug_instr,
    output wire [`DATA_WIDTH-1:0]       debug_alu_result
);

    wire [`ADDR_WIDTH-1:0] pc_current, pc_plus_4, branch_target, jump_addr, next_pc;
    wire [`INSTR_WIDTH-1:0] instr;

    wire [5:0] opcode;
    wire [`REG_ADDR_W-1:0] rs1, rs2, rd;
    wire [3:0] funct;
    wire [25:0] jump_target;
    wire [`DATA_WIDTH-1:0] imm_ext;

    wire reg_write, mem_read, mem_write, mem_to_reg, alu_src;
    wire branch_eq, branch_ne, jump, lui, halt;
    wire [1:0] alu_op_type;
    wire [3:0] alu_op;

    wire [`DATA_WIDTH-1:0] read_data1, read_data2, alu_b, alu_result;
    wire zero, take_branch;
    wire [`DATA_WIDTH-1:0] mem_read_data, writeback_data;

    assign pc_plus_4     = pc_current + 32'd4;
    assign branch_target = pc_plus_4 + (imm_ext << 2);
    assign jump_addr     = {pc_plus_4[31:28], jump_target, 2'b00};

    assign next_pc = jump        ? jump_addr      :
                     take_branch ? branch_target :
                                   pc_plus_4;

    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .en      (cpu_en & ~halt),
        .next_pc (next_pc),
        .pc_out  (pc_current)
    );

    instruction_memory_writable #(.DEPTH(256)) u_imem (
        .clk       (clk),
        .rst       (1'b0),
        .pc_addr   (pc_current),
        .instr     (instr),
        .load_we   (load_we),
        .load_addr (load_addr),
        .load_data (load_data)
    );

    decoder u_decoder (
        .instr       (instr),
        .opcode      (opcode),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .funct       (funct),
        .jump_target (jump_target)
    );

    immediate_generator u_imm_gen (
        .instr   (instr),
        .imm_ext (imm_ext)
    );

    control_unit u_control (
        .opcode      (opcode),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .mem_to_reg  (mem_to_reg),
        .alu_src     (alu_src),
        .branch_eq   (branch_eq),
        .branch_ne   (branch_ne),
        .jump        (jump),
        .lui         (lui),
        .halt        (halt),
        .alu_op_type (alu_op_type)
    );

    alu_control u_alu_control (
        .alu_op_type (alu_op_type),
        .funct       (funct),
        .alu_op      (alu_op)
    );

    wire is_uart_write = mem_write & (alu_result == `UART_TX_ADDR);
    wire reg_write_gated = reg_write & cpu_en & ~halt;
    wire mem_write_gated = mem_write & cpu_en & ~halt & ~is_uart_write;

    register_file u_regfile (
        .clk        (clk),
        .rst        (rst),
        .reg_write  (reg_write_gated),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (writeback_data),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    assign alu_b = alu_src ? imm_ext : read_data2;

    alu u_alu (
        .a      (read_data1),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result),
        .zero   (zero)
    );

    branch_unit u_branch (
        .branch_eq   (branch_eq),
        .branch_ne   (branch_ne),
        .zero        (zero),
        .take_branch (take_branch)
    );

    data_memory #(.DEPTH(256)) u_dmem (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write_gated),
        .addr       (alu_result),
        .write_data (read_data2),
        .read_data  (mem_read_data)
    );

    assign writeback_data = lui ? {instr[15:0], 16'h0000} :
                            mem_to_reg ? mem_read_data :
                            alu_result;

    assign cpu_uart_tx_data  = read_data2[7:0];
    assign cpu_uart_tx_valid = cpu_en & ~halt & is_uart_write & ~cpu_uart_tx_busy;

    assign debug_pc         = pc_current;
    assign debug_instr      = instr;
    assign debug_alu_result = lui ? {instr[15:0], 16'h0000} : alu_result;

endmodule