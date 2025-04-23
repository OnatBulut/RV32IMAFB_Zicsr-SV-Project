`timescale 1ns / 1ps

module rv32_e_fpu (input  logic [`ALU_CONTROL_WIDTH-1:0] fpu_control_i,
                   input  logic [31:0] src_a_i, src_b_i, src_c_i,
                   
                   output logic [31:0] result_o);
                   
    assign result_o = src_a_i + src_b_i + src_c_i + fpu_control_i;
    
endmodule
