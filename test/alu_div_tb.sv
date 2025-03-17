`timescale 1ns / 1ps
`include "../rtl/defines_header.svh"

module alu_div_tb;
    logic clk, rst_n, zero, stall;
    logic [`ALU_CONTROL_WIDTH-1:0] alu_control;
    logic [31:0] src_a, src_b, result;
    
    alu uut (.clk_i(clk),
             .rst_n_i(rst_n),
             .alu_control_i(alu_control),
             .src_a_i(src_a),
             .src_b_i(src_b),
             .zero_o(zero),
             .stall_cpu_o(stall),
             .result_o(result));

    always #1 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        alu_control = ALU_DIVU;
        src_a = 5463;
        src_b = 31;
        
        #2 rst_n = 1;

        wait(stall);
        wait(!stall);
        $display("Quotient: %d", result);
        
        //#2;
        //src_a = 513;
        //src_b = 91;
        //#80;

        //wait(!stall);
        $display("Quotient: %d", result);
        
        #4 $finish;
    end
endmodule
