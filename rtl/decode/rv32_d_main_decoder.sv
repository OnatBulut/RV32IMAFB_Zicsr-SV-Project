`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_d_main_decoder (input  logic [6:0] opcode_i,
                    
                            output logic       branch_o, jump_o, mem_write_o, alu_src_a_o, alu_src_b_o, reg_write_o, pc_target_src_o,
                            output logic [1:0] result_src_o, alu_op_o,
                            output logic [2:0] imm_src_o);
                    
    logic [13:0] control;
                    
    always_comb case(opcode_i)
        OPCODE_RESET:  control = 14'b0_000_0_0_0_00_0_00_0_0; // reset
        OPCODE_LOAD:   control = 14'b1_000_0_1_0_01_0_00_0_0; // I-type / load
        OPCODE_FENCE:  control = 14'b0;                       // Fence
        OPCODE_I_TYPE: control = 14'b1_000_0_1_0_00_0_10_0_0; // I-type / alu ops
        OPCODE_AUIPC:  control = 14'b1_100_1_1_0_00_0_11_0_0; // U-type / auipc
        OPCODE_S_TYPE: control = 14'b0_001_0_1_1_00_0_00_0_0; // S-type
        OPCODE_R_TYPE: control = 14'b1_xxx_0_0_0_00_0_10_0_0; // R-type
        OPCODE_LUI:    control = 14'b1_100_0_1_0_00_0_11_0_0; // U-type / lui
        OPCODE_B_TYPE: control = 14'b0_010_0_0_0_00_1_01_0_0; // B-type
        OPCODE_JALR:   control = 14'b1_000_0_1_0_10_0_00_1_1; // I-type / jalr
        OPCODE_J_TYPE: control = 14'b1_011_0_0_0_10_0_00_1_0; // J-type
        OPCODE_SYSTEM: control = 14'b0;                       // System
        default:       control = 14'bx_xxx_x_x_x_xx_x_xx_x_0;
    endcase
    
    assign {reg_write_o, imm_src_o, alu_src_a_o, alu_src_b_o, mem_write_o, result_src_o, branch_o, alu_op_o, jump_o, pc_target_src_o} = control;

endmodule
