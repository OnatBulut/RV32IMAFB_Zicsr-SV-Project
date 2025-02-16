`timescale 1ns / 1ps

module mux_2_input(input  logic        control_i,
                   input  logic [31:0] in0_i, in1_i,

                   output logic [31:0] out_o);

    assign out_o = control_i ? in1_i : in0_i;

endmodule
