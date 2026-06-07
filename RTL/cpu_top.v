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

    localparam S_FETCH      = 3'd0;
    localparam S_IR_LATCH   = 3'd1;
    localparam S_DECODE     = 3'd2;
    localparam S_EXECUTE    = 3'd3;
    localparam S_MEMORY     = 3'd4;
    localparam S_WRITEBACK  = 3'd5;
    localparam S_HALTED     = 3'd6;

    reg [2:0] state;

    wire [`ADDR_WIDTH-1:0] pc_current;
    reg  [`ADDR_WIDTH-1:0] next_pc_reg;
    wire [`ADDR_WIDTH-1:0] pc_plus_4;

    assign pc_plus_4 = pc_current + 32'd4;

    wire pc_write;
    assign pc_write = (state == S_WRITEBACK) && cpu_en && !halt;

    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .en      (pc_write),
        .next_pc (next_pc_reg),
        .pc_out  (pc_current)
    );

    wire [`INSTR_WIDTH-1:0] imem_instr;
    reg  [`INSTR_WIDTH-1:0] instr_reg;

    instruction_memory_writable #(
        .DEPTH(256)
    ) u_imem (
        .clk       (clk),
        .rst       (rst),
        .pc_addr   (pc_current),
        .instr     (imem_instr),
        .load_we   (load_we),
        .load_addr (load_addr),
        .load_data (load_data)
    );

    wire [5:0] opcode;
    wire [`REG_ADDR_W-1:0] rs1;
    wire [`REG_ADDR_W-1:0] rs2;
    wire [`REG_ADDR_W-1:0] rd;
    wire [3:0] funct;
    wire [25:0] jump_target;

    decoder u_decoder (
        .instr       (instr_reg),
        .opcode      (opcode),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .funct       (funct),
        .jump_target (jump_target)
    );

    wire [`DATA_WIDTH-1:0] imm_ext;

    immediate_generator u_imm_gen (
        .instr   (instr_reg),
        .imm_ext (imm_ext)
    );

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch_eq;
    wire branch_ne;
    wire jump;
    wire lui;
    wire halt;
    wire [1:0] alu_op_type;

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

    wire [3:0] alu_op;

    alu_control u_alu_control (
        .alu_op_type (alu_op_type),
        .funct       (funct),
        .alu_op      (alu_op)
    );

    wire [`DATA_WIDTH-1:0] read_data1;
    wire [`DATA_WIDTH-1:0] read_data2;

    reg [`DATA_WIDTH-1:0] op_a_reg;
    reg [`DATA_WIDTH-1:0] op_b_reg;
    reg [`DATA_WIDTH-1:0] imm_reg;

    reg [`DATA_WIDTH-1:0] alu_result_reg;
    reg [`DATA_WIDTH-1:0] mem_data_reg;

    wire [`DATA_WIDTH-1:0] alu_b;
    wire [`DATA_WIDTH-1:0] alu_result;
    wire zero;
    wire take_branch;

    assign alu_b = alu_src ? imm_reg : op_b_reg;

    alu u_alu (
        .a      (op_a_reg),
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

    wire [`DATA_WIDTH-1:0] writeback_data;

    assign writeback_data = lui        ? {instr_reg[15:0], 16'h0000} :
                            mem_to_reg ? mem_data_reg :
                                         alu_result_reg;

    wire regfile_write_en;
    assign regfile_write_en =
        (state == S_WRITEBACK) &&
        cpu_en &&
        reg_write &&
        !halt;

    register_file u_regfile (
        .clk        (clk),
        .rst        (rst),
        .reg_write  (regfile_write_en),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (writeback_data),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    wire [`DATA_WIDTH-1:0] mem_read_data;

    wire is_uart_write;
    assign is_uart_write = mem_write && (alu_result_reg == `UART_TX_ADDR);

    wire dmem_write_en;
    wire dmem_read_en;

    assign dmem_write_en =
        (state == S_MEMORY) &&
        cpu_en &&
        mem_write &&
        !is_uart_write;

    assign dmem_read_en =
        (state == S_MEMORY) &&
        cpu_en &&
        mem_read;

    data_memory #(
        .DEPTH(256)
    ) u_dmem (
        .clk        (clk),
        .rst        (rst),
        .mem_read   (dmem_read_en),
        .mem_write  (dmem_write_en),
        .addr       (alu_result_reg),
        .write_data (op_b_reg),
        .read_data  (mem_read_data)
    );

    assign cpu_uart_tx_data  = op_b_reg[7:0];

    assign cpu_uart_tx_valid =
        (state == S_MEMORY) &&
        cpu_en &&
        mem_write &&
        is_uart_write &&
        !cpu_uart_tx_busy;

    wire [`ADDR_WIDTH-1:0] branch_target;
    wire [`ADDR_WIDTH-1:0] jump_addr;

    assign branch_target = pc_plus_4 + (imm_reg << 2);
    assign jump_addr     = {pc_plus_4[31:28], jump_target, 2'b00};

    always @(posedge clk) begin
        if (rst) begin
            state          <= S_FETCH;
            instr_reg      <= {`INSTR_WIDTH{1'b0}};
            op_a_reg       <= {`DATA_WIDTH{1'b0}};
            op_b_reg       <= {`DATA_WIDTH{1'b0}};
            imm_reg        <= {`DATA_WIDTH{1'b0}};
            alu_result_reg <= {`DATA_WIDTH{1'b0}};
            mem_data_reg   <= {`DATA_WIDTH{1'b0}};
            next_pc_reg    <= {`ADDR_WIDTH{1'b0}};
        end else if (cpu_en) begin
            case (state)

                S_FETCH: begin
                    state <= S_IR_LATCH;
                end

                S_IR_LATCH: begin
                    instr_reg <= imem_instr;
                    state     <= S_DECODE;
                end

                S_DECODE: begin
                    op_a_reg <= read_data1;
                    op_b_reg <= read_data2;
                    imm_reg  <= imm_ext;
                    state    <= S_EXECUTE;
                end

                S_EXECUTE: begin
                    if (lui) begin
                        alu_result_reg <= {instr_reg[15:0], 16'h0000};
                    end else if (!halt) begin
                        alu_result_reg <= alu_result;
                    end

                    if (jump) begin
                        next_pc_reg <= jump_addr;
                    end else if (take_branch) begin
                        next_pc_reg <= branch_target;
                    end else begin
                        next_pc_reg <= pc_plus_4;
                    end

                    if (halt) begin
                        state <= S_WRITEBACK;
                    end else if (mem_read || mem_write) begin
                        state <= S_MEMORY;
                    end else begin
                        state <= S_WRITEBACK;
                    end
                end

                S_MEMORY: begin
                    if (is_uart_write && cpu_uart_tx_busy) begin
                        state <= S_MEMORY;
                    end else begin
                        mem_data_reg <= mem_read_data;
                        state        <= S_WRITEBACK;
                    end
                end

                S_WRITEBACK: begin
                    if (halt) begin
                        state <= S_HALTED;
                    end else begin
                        state <= S_FETCH;
                    end
                end

                S_HALTED: begin
                    state <= S_HALTED;
                end

                default: begin
                    state <= S_FETCH;
                end

            endcase
        end
    end

    assign debug_pc         = pc_current;
    assign debug_instr      = instr_reg;
    assign debug_alu_result = alu_result_reg;

endmodule