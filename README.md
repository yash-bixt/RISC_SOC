# 32-Bit RISC Processor SoC

A custom **32-bit Harvard Architecture RISC System-on-Chip (SoC)** designed in Verilog HDL featuring a custom Instruction Set Architecture (ISA), Python-based assembler, UART program loading framework, FPGA validation on a Xilinx Artix-7 FPGA, and complete RTL-to-GDSII ASIC implementation using the **SCL 180nm Standard Cell Library** and **Synopsys EDA Toolchain**.

The project demonstrates the complete semiconductor design flow, spanning processor architecture, RTL development, FPGA prototyping, custom software toolchain development, physical design, timing analysis, and ASIC implementation.

---

# Project Highlights

## Processor Design

* Custom 32-Bit Harvard Architecture RISC Processor
* Single-Cycle CPU Architecture
* Custom Instruction Set Architecture (ISA)
* 32-Bit Datapath
* Branch & Jump Support
* Memory Access Instructions
* Arithmetic & Logical Operations
* Shift & Comparison Operations
* UART-Based Program Loading

## Software Toolchain

* Custom Python-Based Assembler
* Assembly-to-Machine-Code Translation
* HEX File Generation
* UART Program Upload Utility
* Automated Instruction Encoding

## FPGA Implementation

* FPGA Validation on Digilent Nexys-4
* Xilinx Artix-7 XC7A100T FPGA
* Vivado Design Suite
* UART-Based Program Deployment
* Real-Time Hardware Execution

## ASIC Implementation

* SCL 180nm Standard Cell Library
* Synopsys Design Compiler
* Synopsys IC Compiler II (ICC2)
* Synopsys PrimeTime
* Synopsys Verdi
* RTL-to-GDSII Flow
* SRAM Macro Integration
* SPEF Extraction
* Timing Analysis
* Power Analysis

---

# Project Overview

The goal of this project was to design and implement a complete custom processor system from architecture definition through physical implementation.

A custom 32-bit RISC processor was developed using a Harvard memory architecture with independent instruction and data memory paths. A custom ISA was created to support arithmetic, logical, memory-access, and control-flow operations.

To enable software execution on hardware, a Python-based assembler was developed to translate assembly programs into machine code and FPGA-compatible HEX images. Programs are transferred to the FPGA using a UART communication framework and executed directly by the processor.

After successful FPGA validation, the design was implemented through a complete ASIC flow including synthesis, floorplanning, placement, clock tree synthesis, routing, parasitic extraction, timing analysis, and GDSII generation.

---

# Processor Architecture

## Architectural Features

| Feature            | Description                          |
| ------------------ | ------------------------------------ |
| Architecture       | Harvard RISC                         |
| Datapath Width     | 32-bit                               |
| Execution Model    | Single-Cycle                         |
| Instruction Format | Custom ISA                           |
| Program Loading    | UART                                 |
| Memory System      | Separate Instruction & Data Memories |
| ASIC Technology    | SCL 180nm                            |

---

## Major Hardware Blocks

### CPU Core

* Program Counter (PC)
* Control Unit
* Instruction Decoder
* Register File
* Arithmetic Logic Unit (ALU)
* Branch & Jump Logic

### Memory Subsystem

* Instruction Memory
* Data Memory
* SRAM Macro Integration (ASIC)

### Communication

* UART Receiver
* UART Program Loader
* Host-to-FPGA Program Transfer

### Peripherals

* Memory-Mapped I/O
* LED Interface
* Seven-Segment Display Interface

---

# Custom Instruction Set Architecture

The processor implements a custom ISA supporting:

## Arithmetic Instructions

* ADD
* SUB
* MUL

## Logical Instructions

* AND
* OR
* XOR

## Shift Instructions

* SLL
* SRL
* SRA

## Comparison Instructions

* SLT
* SLTU

## Immediate Instructions

* ADDI
* LUI

## Memory Instructions

* LW
* SW

## Control Flow Instructions

* BEQ
* BNE
* J

## System Instructions

* NOP
* HALT

---

# Software Toolchain

A complete software deployment workflow was developed for the processor.

## Python Assembler

The custom assembler:

* Parses custom assembly programs
* Encodes instructions into machine code
* Generates FPGA-compatible HEX files
* Supports label resolution and branching
* Automates program image generation

## Deployment Flow

1. Write assembly program
2. Assemble source code
3. Generate HEX image
4. Transfer image via UART
5. Load instructions into Instruction Memory
6. Execute program on FPGA
7. Observe results through hardware peripherals

---

# FPGA Validation

The complete SoC was validated on a Digilent Nexys-4 development board based on the Xilinx Artix-7 FPGA.

## FPGA Platform

| Parameter         | Value            |
| ----------------- | ---------------- |
| FPGA Board        | Digilent Nexys-4 |
| FPGA Device       | XC7A100T         |
| FPGA Family       | Xilinx Artix-7   |
| Toolchain         | Vivado           |
| System Clock      | 100 MHz          |
| Program Interface | UART             |

## Validation Features

* UART Program Upload
* Instruction Execution Verification
* ALU Operation Verification
* Branch Execution Verification
* Memory Read/Write Verification
* Real-Time Hardware Debugging

---

# ASIC Implementation Flow

The design was taken through a complete RTL-to-GDSII ASIC implementation flow.

## Tool Flow

| Stage                | Tool                     |
| -------------------- | ------------------------ |
| RTL Verification     | Verilog Testbenches      |
| Synthesis            | Synopsys Design Compiler |
| Debug & Analysis     | Synopsys Verdi           |
| Floorplanning        | Synopsys ICC2            |
| Placement            | Synopsys ICC2            |
| Clock Tree Synthesis | Synopsys ICC2            |
| Routing              | Synopsys ICC2            |
| SPEF Extraction      | Synopsys ICC2            |
| Timing Analysis      | Synopsys PrimeTime       |
| GDS Generation       | Synopsys ICC2            |

---

## Physical Design Stages

* RTL Verification
* Logic Synthesis
* Floorplanning
* Power Planning
* SRAM Macro Placement
* Standard Cell Placement
* Clock Tree Synthesis (CTS)
* Routing
* SPEF Extraction
* Static Timing Analysis (STA)
* GDSII Generation

---

# ASIC Implementation Results

## Timing Results

| Metric                     | Value    |
| -------------------------- | -------- |
| Clock Period               | 20 ns    |
| Target Frequency           | 50 MHz   |
| Critical Path Delay        | 19.61 ns |
| Worst Negative Slack (WNS) | 0.00 ns  |
| Total Negative Slack (TNS) | 0.00 ns  |
| Setup Violations           | 0        |
| Hold Violations            | 0        |

### Timing Status

✅ Timing Closure Achieved

✅ Zero Setup Violations

✅ Zero Hold Violations

---

## Cell Statistics

| Metric               | Value |
| -------------------- | ----- |
| Total Standard Cells | 8,687 |
| Combinational Cells  | 7,151 |
| Sequential Cells     | 1,536 |
| Buffers/Inverters    | 1,025 |
| Memory Macros        | 8     |
---

## Physical Metrics

| Metric                  | Value           |
| ----------------------- | --------------- |
| Core Area               | 824,535.94 μm²  |
| Standard Cell Area      | 240,352.45 μm²  |
| SRAM Macro Area         | 235,639.04 μm²  |
| Macro Keepout Area      | 183,129.86 μm²  |
| Final Utilization       | 46.91%          |
| Routed Nets             | 57,784          |
| Total Routed Wirelength | 8.25 Million μm |

---

## Power Results

| Metric        | Value   |
| ------------- | ------- |
| Dynamic Power | 9.06 mW |
| Leakage Power | 3.36 μW |
| Total Power   | 9.07 mW |

---

# Skills Demonstrated

### Computer Architecture

* RISC Processor Design
* Harvard Architecture
* ISA Development
* Datapath Design
* Control Logic Design

### RTL Design

* Verilog HDL
* RTL Verification
* Simulation & Debug

### FPGA Design

* Vivado
* FPGA Prototyping
* UART Communication
* Hardware Validation

### ASIC Design

* Design Compiler
* IC Compiler II
* PrimeTime
* Verdi
* Physical Design
* Floorplanning
* CTS
* Routing
* Timing Closure
* Power Analysis
* GDSII Generation

### Software Development

* Python
* Assembler Development
* Machine Code Generation
* UART Deployment Tools

---

# Author

**Yash Sharma**

Electrical & Computer Engineering
Shiv Nadar University

GitHub: https://github.com/yash-bixt
