# 32-Bit RISC Processor SoC

Custom 32-bit RISC Processor System-on-Chip designed in Verilog HDL with a custom ISA, UART-based program loading, FPGA validation on Xilinx Artix-7, and complete RTL-to-GDSII ASIC implementation using the SCL 180nm Standard Cell Library and Synopsys EDA toolchain.

## Highlights

* Custom 32-bit RISC CPU Architecture
* Custom ISA and Assembler
* UART-Based Program Loading Framework
* FPGA Validation using Xilinx Vivado
* Digilent Nexys-4 (Artix-7) Deployment
* 100 MHz FPGA Operation
* RTL-to-GDSII ASIC Implementation
* SCL 180nm Standard Cell Library
* Synopsys Design Compiler, ICC2, PrimeTime & Verdi
* 8,687 Standard Cells
* 8 SRAM Macros
* 10,172 Routed Nets
* 461,634 µm² Cell Area
* 46.9% Core Utilization
* 0 Setup Violations
* 0 Hold Violations

## Project Overview

This project implements a custom 32-bit RISC Processor SoC from RTL design through FPGA validation and ASIC physical implementation. The processor was designed in Verilog HDL with a custom instruction set architecture and a dedicated assembler for converting assembly programs into machine code.

Programs are transferred to the FPGA through a UART-based programming interface, loaded into instruction memory, and executed directly in hardware. The design was validated on a Xilinx Artix-7 FPGA operating at 100 MHz.

Following FPGA verification, the same RTL was implemented through a complete ASIC design flow using the SCL 180nm technology library and Synopsys EDA tools.

## Architecture

### CPU Components

* 32-Bit ALU
* Register File
* Control Unit
* Instruction Decoder
* Program Counter
* Branch & Jump Logic
* Instruction Memory
* Data Memory
* UART Programming Interface
* Memory-Mapped I/O

### Software Toolchain

* Custom ISA Definition
* Custom Assembler
* Hex File Generation
* UART Program Transfer Utility

## FPGA Validation Flow

1. Write program using custom ISA
2. Assemble source code into machine instructions
3. Generate HEX image
4. Transfer program through UART
5. Load instructions into Instruction Memory
6. Execute instructions on FPGA
7. Observe execution results through LEDs and Seven-Segment Displays

### FPGA Platform

| Parameter         | Value                   |
|-------------------|-------------------------|
| FPGA Board        | Digilent Nexys-4        |
| FPGA Device       | Xilinx Artix-7 XC7A100T |
| FPGA Toolchain    | Xilinx Vivado           |
| Clock Frequency   | 100 MHz                 |
| Program Interface | UART                    |

## ASIC Implementation Flow

The design was implemented using industry-standard ASIC design methodologies.

### Tool Flow

| Stage                  | Tool                     |
| ---------------------- | ------------------------ |
| RTL Verification       | Verilog Testbenches      |
| Logic Synthesis        | Synopsys Design Compiler |
| Debug & Analysis       | Synopsys Verdi           |
| Floorplanning          | Synopsys IC Compiler II  |
| Placement              | Synopsys IC Compiler II  |
| Clock Tree Synthesis   | Synopsys IC Compiler II  |
| Routing                | Synopsys IC Compiler II  |
| Static Timing Analysis | Synopsys PrimeTime       |

### Physical Design Stages

* RTL Verification
* Logic Synthesis
* Floorplanning
* Power Planning
* Standard Cell Placement
* Clock Tree Synthesis (CTS)
* Routing
* Static Timing Analysis (STA)
* Physical Verification

## ASIC Results

| Metric              | Value       |
| ------------------- | ----------- |
| Technology          | SCL 180nm   |
| Standard Cells      | 8,687       |
| Combinational Cells | 7,151       |
| Sequential Cells    | 1,536       |
| SRAM Macros         | 8           |
| Routed Nets         | 10,172      |
| Cell Area           | 461,634 µm² |
| Core Utilization    | 46.9%       |
| Setup Violations    | 0           |
| Hold Violations     | 0           |

### Timing Summary

* Timing Closure Achieved
* Zero Setup Violations
* Zero Hold Violations
* Successfully Completed RTL-to-GDSII Flow


## Skills Demonstrated

* Computer Architecture
* RTL Design
* Verilog HDL
* FPGA Prototyping
* Xilinx Vivado
* UART Communication
* Custom ISA Design
* Assembler Development
* ASIC Design Flow
* Physical Design
* Static Timing Analysis (STA)
* Clock Tree Synthesis (CTS)
* Synopsys Design Compiler
* Synopsys IC Compiler II
* Synopsys PrimeTime
* Synopsys Verdi

## Author

**Yash Sharma**
Electrical & Computer Engineering
Shiv Nadar University

GitHub: https://github.com/yash-bixt
