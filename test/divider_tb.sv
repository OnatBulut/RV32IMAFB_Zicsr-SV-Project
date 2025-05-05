`timescale 1ns / 1ps
`include "defines_header.svh"

module divider_tb;
    logic clk, rst_n;
    logic [`ALU_CONTROL_WIDTH-1:0] alu_control;
    logic [31:0] rd1, rd2;
    logic [31:0] result;
    logic done, running;

    rv32_mul_div uut (.clk_i(clk),
                      .rst_n_i(rst_n),
                      .alu_control_i(alu_control),
                      .read_data_1_i(rd1),
                      .read_data_2_i(rd2),
                      .running_o(running),
                      .done_o(done),
                      .result_o(result));

    always #1 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        #2 rst_n = 1;
        
        alu_control = ALU_DIV;
        rd1 = -5463;
        rd2 = 31;
        
        #2;
        
        alu_control = ALU_MUL;
        rd1 = 20;
        rd2 = 5;

        wait(done);
        $display("Quotient: %d", $signed(result));
        
        alu_control = ALU_REM;
        rd1 = 600;
        rd2 = 27;
        
        #4;
        
        wait(done);
        $display("Remainder: %d", $signed(result));
        
        #4 $finish;
    end
endmodule
