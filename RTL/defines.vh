`ifndef DEFINES_VH
`define DEFINES_VH

`define DATA_WIDTH  32
`define ADDR_WIDTH  32
`define REG_COUNT   32
`define REG_ADDR_W  5
`define INSTR_WIDTH 32

`define IMEM_DEPTH 256
`define DMEM_DEPTH 256
`define MEM_ADDR_W 8

`define OPCODE_MSB 31
`define OPCODE_LSB 26
`define RS1_MSB    25
`define RS1_LSB    21
`define RS2_MSB    20
`define RS2_LSB    16
`define RD_R_MSB   15
`define RD_R_LSB   11
`define RD_I_MSB   20
`define RD_I_LSB   16
`define IMM_MSB    15
`define IMM_LSB    0
`define JADDR_MSB  25
`define JADDR_LSB  0

`define OP_RTYPE 6'b000000
`define OP_ADDI  6'b000001
`define OP_LW    6'b000010
`define OP_SW    6'b000011
`define OP_BEQ   6'b000100
`define OP_BNE   6'b000101
`define OP_J     6'b000110
`define OP_LUI   6'b000111
`define OP_HALT  6'b111110
`define OP_NOP   6'b111111

`define FUNCT_ADD  4'b0000
`define FUNCT_SUB  4'b0001
`define FUNCT_AND  4'b0010
`define FUNCT_OR   4'b0011
`define FUNCT_XOR  4'b0100
`define FUNCT_MUL  4'b0101
`define FUNCT_DIV  4'b0110
`define FUNCT_MOD  4'b0111
`define FUNCT_SLL  4'b1000
`define FUNCT_SRL  4'b1001
`define FUNCT_SRA  4'b1010
`define FUNCT_SLT  4'b1011
`define FUNCT_SLTU 4'b1100

`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_MUL  4'b0101
`define ALU_DIV  4'b0110
`define ALU_MOD  4'b0111
`define ALU_SLL  4'b1000
`define ALU_SRL  4'b1001
`define ALU_SRA  4'b1010
`define ALU_SLT  4'b1011
`define ALU_SLTU 4'b1100
`define ALU_PASS 4'b1111

`define UART_TX_ADDR 32'hFFFF0000

`endif