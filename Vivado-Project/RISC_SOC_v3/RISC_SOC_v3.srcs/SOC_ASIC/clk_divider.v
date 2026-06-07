`timescale 1ns/1ps
module clk_divider(
input wire clk_100mhz,
rst,fast_sel,
output wire clk_cpu,
clk_slow
);
reg [26:0] counter; 
always @(posedge clk_100mhz) begin 
if(rst) counter<=0;
 else counter<=counter+1; 
 
 end
assign clk_slow=counter[25]; 

assign clk_cpu=fast_sel?counter[3]:counter[25];

endmodule
