`timescale 1ns / 1ps

module mux_3_input(input  logic [1:0]  control_i,
                   input  logic [31:0] in0_i, in1_i, in2_i,
                  
                   output logic [31:0] out_o);
    
    always_comb case(control_i)
        2'b00:   out_o = in0_i;
        2'b01:   out_o = in1_i;
        2'b10:   out_o = in2_i;
        default: out_o = 32'bx;
    endcase
        
endmodule