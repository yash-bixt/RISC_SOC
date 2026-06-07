`timescale 1ns/1ps


module branch_unit(
input wire branch_eq,
branch_ne,zero,
output wire take_branch
);


assign take_branch=(branch_eq&&zero)||(branch_ne&&!zero);



endmodule
