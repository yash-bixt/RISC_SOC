## =========================================================
## Nexys 4 Rev B XDC - UART RISC SoC
## Top module: nexys4_top
## =========================================================

## CLOCK: 100 MHz
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports CLK100MHZ]


## RESET + CENTER BUTTON
set_property PACKAGE_PIN C12 [get_ports CPU_RESETN]
set_property IOSTANDARD LVCMOS33 [get_ports CPU_RESETN]

set_property PACKAGE_PIN E16 [get_ports BTNC]
set_property IOSTANDARD LVCMOS33 [get_ports BTNC]


## SWITCHES
set_property PACKAGE_PIN U9 [get_ports {SW[0]}]
set_property PACKAGE_PIN U8 [get_ports {SW[1]}]
set_property PACKAGE_PIN R7 [get_ports {SW[2]}]
set_property PACKAGE_PIN R6 [get_ports {SW[3]}]
set_property PACKAGE_PIN R5 [get_ports {SW[4]}]
set_property PACKAGE_PIN V7 [get_ports {SW[5]}]
set_property PACKAGE_PIN V6 [get_ports {SW[6]}]
set_property PACKAGE_PIN V5 [get_ports {SW[7]}]
set_property PACKAGE_PIN U4 [get_ports {SW[8]}]
set_property PACKAGE_PIN V2 [get_ports {SW[9]}]
set_property PACKAGE_PIN U2 [get_ports {SW[10]}]
set_property PACKAGE_PIN T3 [get_ports {SW[11]}]
set_property PACKAGE_PIN T1 [get_ports {SW[12]}]
set_property PACKAGE_PIN R3 [get_ports {SW[13]}]
set_property PACKAGE_PIN P3 [get_ports {SW[14]}]
set_property PACKAGE_PIN P4 [get_ports {SW[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[*]}]


## LEDS
set_property PACKAGE_PIN T8 [get_ports {LED[0]}]
set_property PACKAGE_PIN V9 [get_ports {LED[1]}]
set_property PACKAGE_PIN R8 [get_ports {LED[2]}]
set_property PACKAGE_PIN T6 [get_ports {LED[3]}]
set_property PACKAGE_PIN T5 [get_ports {LED[4]}]
set_property PACKAGE_PIN T4 [get_ports {LED[5]}]
set_property PACKAGE_PIN U7 [get_ports {LED[6]}]
set_property PACKAGE_PIN U6 [get_ports {LED[7]}]
set_property PACKAGE_PIN V4 [get_ports {LED[8]}]
set_property PACKAGE_PIN U3 [get_ports {LED[9]}]
set_property PACKAGE_PIN V1 [get_ports {LED[10]}]
set_property PACKAGE_PIN R1 [get_ports {LED[11]}]
set_property PACKAGE_PIN P5 [get_ports {LED[12]}]
set_property PACKAGE_PIN U1 [get_ports {LED[13]}]
set_property PACKAGE_PIN R2 [get_ports {LED[14]}]
set_property PACKAGE_PIN P2 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]


## 7-SEGMENT DISPLAY
set_property PACKAGE_PIN N6 [get_ports {AN[0]}]
set_property PACKAGE_PIN M6 [get_ports {AN[1]}]
set_property PACKAGE_PIN M3 [get_ports {AN[2]}]
set_property PACKAGE_PIN N5 [get_ports {AN[3]}]
set_property PACKAGE_PIN N2 [get_ports {AN[4]}]
set_property PACKAGE_PIN N4 [get_ports {AN[5]}]
set_property PACKAGE_PIN L1 [get_ports {AN[6]}]
set_property PACKAGE_PIN M1 [get_ports {AN[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[*]}]

set_property PACKAGE_PIN L3 [get_ports CA]
set_property PACKAGE_PIN N1 [get_ports CB]
set_property PACKAGE_PIN L5 [get_ports CC]
set_property PACKAGE_PIN L4 [get_ports CD]
set_property PACKAGE_PIN K3 [get_ports CE]
set_property PACKAGE_PIN M2 [get_ports CF]
set_property PACKAGE_PIN L6 [get_ports CG]
set_property PACKAGE_PIN M4 [get_ports DP]

set_property IOSTANDARD LVCMOS33 [get_ports CA]
set_property IOSTANDARD LVCMOS33 [get_ports CB]
set_property IOSTANDARD LVCMOS33 [get_ports CC]
set_property IOSTANDARD LVCMOS33 [get_ports CD]
set_property IOSTANDARD LVCMOS33 [get_ports CE]
set_property IOSTANDARD LVCMOS33 [get_ports CF]
set_property IOSTANDARD LVCMOS33 [get_ports CG]
set_property IOSTANDARD LVCMOS33 [get_ports DP]


## USB-UART BRIDGE
## Manual page 9: FT2232 USB-UART uses FPGA pins C4 and D4.
## Master XDC names:
## C4 = UART_TXD_IN  = data from PC to FPGA
## D4 = UART_RXD_OUT = data from FPGA to PC

set_property PACKAGE_PIN C4 [get_ports UART_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RXD]

set_property PACKAGE_PIN D4 [get_ports UART_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TXD]