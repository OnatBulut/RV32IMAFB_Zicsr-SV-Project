`timescale 1ns / 1ps

module program_counter_target(input  logic [31:0] pc_i, imm_ext_i,

                              output logic [31:0] pc_target_o);

    assign pc_target_o = pc_i + imm_ext_i;

endmodule