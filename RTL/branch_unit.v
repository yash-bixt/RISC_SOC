`timescale 1ns/1ps

module branch_unit (
    input  wire branch_eq,
    input  wire branch_ne,
    input  wire zero,

    output wire take_branch
);

assign take_branch =
        (branch_eq &&  zero) ||
        (branch_ne && !zero);

endmodule