`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_d_main_decoder (input  logic [6:0] opcode_i,
                    
                            output logic       valid_instr_o,
                            output logic       branch_o, jump_o, mem_write_o, alu_src_a_o, alu_src_b_o, reg_write_o, pc_target_src_o,
                            output logic [1:0] result_src_o, alu_op_o,
                            output logic [2:0] imm_src_o);
                    
    logic [13:0] control;
                    
    always_comb case(opcode_i)
            OPCODE_RESET:  begin control = 14'b0_000_0_0_0_00_0_00_0_0; valid_instr_o = 1'b0; end  // reset
            OPCODE_LOAD:   begin control = 14'b1_000_0_1_0_01_0_00_0_0; valid_instr_o = 1'b1; end  // I-type / load
            OPCODE_FENCE:  begin control = 14'b0;                       valid_instr_o = 1'b1; end  // I-type / Fence 14'b?_000_0_0_0_??_?_??_?_?
            OPCODE_I_TYPE: begin control = 14'b1_000_0_1_0_00_0_10_0_0; valid_instr_o = 1'b1; end  // I-type / alu ops
            OPCODE_AUIPC:  begin control = 14'b1_100_1_1_0_00_0_11_0_0; valid_instr_o = 1'b1; end  // U-type / auipc
            OPCODE_S_TYPE: begin control = 14'b0_001_0_1_1_00_0_00_0_0; valid_instr_o = 1'b1; end  // S-type
            OPCODE_R_TYPE: begin control = 14'b1_xxx_0_0_0_00_0_10_0_0; valid_instr_o = 1'b1; end  // R-type
            OPCODE_LUI:    begin control = 14'b1_100_0_1_0_00_0_11_0_0; valid_instr_o = 1'b1; end  // U-type / lui
            OPCODE_B_TYPE: begin control = 14'b0_010_0_0_0_00_1_01_0_0; valid_instr_o = 1'b1; end  // B-type
            OPCODE_JALR:   begin control = 14'b1_000_0_1_0_10_0_00_1_1; valid_instr_o = 1'b1; end  // I-type / jalr
            OPCODE_J_TYPE: begin control = 14'b1_011_0_0_0_10_0_00_1_0; valid_instr_o = 1'b1; end  // J-type
            OPCODE_SYSTEM: begin control = 14'b0;                       valid_instr_o = 1'b1; end  // I-type / System 14'b?_000_0_0_0_11_?_??_?_?
            default:       begin control = 14'bx_xxx_x_x_x_xx_x_xx_x_x; valid_instr_o = 1'b0; end
    endcase
    
    assign {reg_write_o, imm_src_o, alu_src_a_o, alu_src_b_o, mem_write_o, result_src_o, branch_o, alu_op_o, jump_o, pc_target_src_o} = control;

endmodule
