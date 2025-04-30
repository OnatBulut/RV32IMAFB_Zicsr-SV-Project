`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_d_main_decoder (input  logic [6:0] opcode_i,
                    
                            output logic       valid_instr_o,
                            output logic       branch_o, jump_o, mem_write_o, mem_data_src_o, alu_src_a_o, alu_src_b_o, reg_write_o, fp_reg_write_o, pc_target_src_o,
                            output logic [2:0] result_src_o, imm_src_o,
                            output logic [3:0] alu_op_o);
                    
    logic [18:0] control;
                    
    always_comb case(opcode_i)
            OPCODE_RESET:    begin control = 19'b0_0_000_0_0_0_0_000_0_0000_0_0; valid_instr_o = 1'b0; end  // reset
            OPCODE_LOAD:     begin control = 19'b1_0_000_0_1_0_0_001_0_0000_0_0; valid_instr_o = 1'b1; end  // I-type / load
            OPCODE_FENCE:    begin control = 19'b0;                              valid_instr_o = 1'b1; end  // I-type / Fence 14'b?_000_0_0_0_??_?_??_?_?
            OPCODE_I_TYPE:   begin control = 19'b1_0_000_0_1_0_0_000_0_0010_0_0; valid_instr_o = 1'b1; end  // I-type / ALU Ops
            OPCODE_AUIPC:    begin control = 19'b1_0_100_1_1_0_0_000_0_0011_0_0; valid_instr_o = 1'b1; end  // U-type / auipc
            OPCODE_S_TYPE:   begin control = 19'b0_0_001_0_1_1_0_000_0_0000_0_0; valid_instr_o = 1'b1; end  // S-type
            OPCODE_R_TYPE:   begin control = 19'b1_0_xxx_0_0_0_0_000_0_0010_0_0; valid_instr_o = 1'b1; end  // R-type
            OPCODE_LUI:      begin control = 19'b1_0_100_0_1_0_0_000_0_0011_0_0; valid_instr_o = 1'b1; end  // U-type / lui
            OPCODE_B_TYPE:   begin control = 19'b0_0_010_0_0_0_0_000_1_0001_0_0; valid_instr_o = 1'b1; end  // B-type
            OPCODE_JALR:     begin control = 19'b1_0_000_0_1_0_0_010_0_0000_1_1; valid_instr_o = 1'b1; end  // I-type / jalr
            OPCODE_J_TYPE:   begin control = 19'b1_0_011_0_0_0_0_010_0_0000_1_0; valid_instr_o = 1'b1; end  // J-type
            OPCODE_SYSTEM:   begin control = 19'b0;                              valid_instr_o = 1'b1; end  // I-type / System 14'b?_000_0_0_0_11_?_??_?_?
            OPCODE_LOAD_FP:  begin control = 19'b0_1_000_0_1_0_1_001_0_0000_0_0; valid_instr_o = 1'b1; end  // Single Precision Floating Point Load
            OPCODE_STORE_FP: begin control = 19'b0_0_001_0_1_1_1_000_0_0000_0_0; valid_instr_o = 1'b1; end  // Single Precision Floating Point Store
            OPCODE_FP:       begin control = 19'b0_1_xxx_0_0_0_0_100_0_0100_0_0; valid_instr_o = 1'b1; end  // Single Precision FPU Ops
            OPCODE_MADD:     begin control = 19'b0_1_xxx_0_0_0_0_100_0_0101_0_0; valid_instr_o = 1'b1; end  // Single Precision FPU Multiply Sub
            OPCODE_MSUB:     begin control = 19'b0_1_xxx_0_0_0_0_100_0_0110_0_0; valid_instr_o = 1'b1; end  // Single Precision FPU Multiply Sub
            OPCODE_NMSUB:    begin control = 19'b0_1_xxx_0_0_0_0_100_0_0111_0_0; valid_instr_o = 1'b1; end  // Single Precision FPU Negated Multiply Sub
            OPCODE_NMADD:    begin control = 19'b0_1_xxx_0_0_0_0_100_0_1000_0_0; valid_instr_o = 1'b1; end  // Single Precision FPU Negated Multiply Add
            default:         begin control = 19'bx;                              valid_instr_o = 1'b0; end  // Invalid OPCODE
    endcase
    
    assign {reg_write_o, fp_reg_write_o, imm_src_o, alu_src_a_o, alu_src_b_o, mem_write_o, mem_data_src_o, result_src_o, branch_o, alu_op_o, jump_o, pc_target_src_o} = control;

endmodule
