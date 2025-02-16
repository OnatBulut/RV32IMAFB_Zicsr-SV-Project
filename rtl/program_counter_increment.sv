`timescale 1ns / 1ps

module program_counter_increment(input  logic [31:0] pc_i,

                                 output logic [31:0] pc_plus_4_o);

    assign pc_plus_4_o = pc_i + 32'h4;

endmodule