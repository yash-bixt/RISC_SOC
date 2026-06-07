`timescale 1ns/1ps

module program_loader (
    input  wire        clk,
    input  wire        rst,

    input  wire [7:0]  ascii_char,
    input  wire        ascii_valid,

    input  wire [31:0] instruction_word,
    input  wire        instruction_valid,

    output reg         load_we,
    output reg  [7:0]  load_addr,
    output reg  [31:0] load_data,

    output reg         cpu_run,
    output reg         cpu_reset,

    output reg         loaded_pulse,
    output reg         run_pulse
);

    localparam STATE_LOAD = 1'b0;
    localparam STATE_RUN  = 1'b1;

    reg        state;
    reg [23:0] cmd_shift;
    reg [23:0] next_cmd_shift;
    reg [7:0]  ascii_upper;

    always @(*) begin
        ascii_upper    = ascii_char;
        next_cmd_shift = {cmd_shift[15:0], ascii_char};

        if ((ascii_char >= "a") && (ascii_char <= "z")) begin
            ascii_upper = ascii_char - 8'd32;
        end

        next_cmd_shift = {cmd_shift[15:0], ascii_upper};
    end

    always @(posedge clk) begin
        if (rst) begin
            state        <= STATE_LOAD;
            load_we      <= 1'b0;
            load_addr    <= 8'd0;
            load_data    <= 32'd0;
            cpu_run      <= 1'b0;
            cpu_reset    <= 1'b1;
            cmd_shift    <= 24'd0;
            loaded_pulse <= 1'b0;
            run_pulse    <= 1'b0;
        end else begin
            load_we      <= 1'b0;
            loaded_pulse <= 1'b0;
            run_pulse    <= 1'b0;

            if (ascii_valid) begin
                cmd_shift <= next_cmd_shift;
            end

            case (state)

                STATE_LOAD: begin
                    cpu_run   <= 1'b0;
                    cpu_reset <= 1'b1;

                    if (instruction_valid) begin
                        load_data    <= instruction_word;
                        load_we      <= 1'b1;
                        load_addr    <= load_addr + 8'd1;
                        loaded_pulse <= 1'b1;
                    end

                    if (ascii_valid && (next_cmd_shift == {"R", "U", "N"})) begin
                        state     <= STATE_RUN;
                        cpu_run   <= 1'b1;
                        cpu_reset <= 1'b0;
                        run_pulse <= 1'b1;
                    end
                end

                STATE_RUN: begin
                    cpu_run   <= 1'b1;
                    cpu_reset <= 1'b0;
                end

                default: begin
                    state     <= STATE_LOAD;
                    cpu_run   <= 1'b0;
                    cpu_reset <= 1'b1;
                end

            endcase
        end
    end

endmodule