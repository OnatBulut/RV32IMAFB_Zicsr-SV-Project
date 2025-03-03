`timescale 1ns / 1ps

module main_decoder(input  logic [6:0] op_i,
                    
                    output logic       branch_o, jump_o, mem_write_o, alu_src_a_o, alu_src_b_o, reg_write_o, pc_target_src_o,
                    output logic [1:0] result_src_o, alu_op_o,
                    output logic [2:0] imm_src_o);
                    
    logic [13:0] control;
                    
    always_comb case(op_i)
        7'b000_0000: control = 14'b0_000_0_0_0_00_0_00_0_0; // reset
        7'b000_0011: control = 14'b1_000_0_1_0_01_0_00_0_0; // I-type / load
        7'b001_0011: control = 14'b1_000_0_1_0_00_0_10_0_0; // I-type / alu ops
        7'b001_0111: control = 14'b1_100_1_1_0_00_0_11_0_0; // U-type / auipc
        7'b010_0011: control = 14'b0_001_0_1_1_00_0_00_0_0; // S-type
        7'b011_0011: control = 14'b1_xxx_0_0_0_00_0_10_0_0; // R-type
        7'b011_0111: control = 14'b1_100_0_1_0_00_0_11_0_0; // U-type / lui
        7'b110_0011: control = 14'b0_010_0_0_0_00_1_01_0_0; // B-type
        7'b110_0111: control = 14'b1_000_0_1_0_10_0_00_1_1; // I-type / jalr
        7'b110_1111: control = 14'b1_011_0_0_0_10_0_00_1_0; // J-type
        default:     control = 14'bx_xxx_x_x_x_xx_x_xx_x_0;
    endcase
    
    assign {reg_write_o, imm_src_o, alu_src_a_o, alu_src_b_o, mem_write_o, result_src_o, branch_o, alu_op_o, jump_o, pc_target_src_o} = control;

endmodule
