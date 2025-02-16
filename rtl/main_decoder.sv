`timescale 1ns / 1ps

module main_decoder(input  logic [6:0] op_i,
                    
                    output logic       branch_o, jump_o, mem_write_o, alu_src_o, reg_write_o,
                    output logic [1:0] result_src_o, imm_src_o, alu_op_o);
                    
    logic [10:0] control;
                    
    always_comb case(op_i)
        7'b000_0000: control = 11'b0_00_0_0_00_0_00_0; // reset
        7'b000_0011: control = 11'b1_00_1_0_01_0_00_0; // lw
        7'b001_0011: control = 11'b1_00_1_0_00_0_10_0; // I-type
        7'b010_0011: control = 11'b0_01_1_1_00_0_00_0; // sw
        7'b011_0011: control = 11'b1_xx_0_0_00_0_10_0; // R-type
        7'b110_0011: control = 11'b0_10_0_0_00_1_01_0; // beq
        7'b110_1111: control = 11'b1_11_0_0_10_0_00_1; // jal
        default:     control = 11'bx_xx_x_x_xx_x_xx_x;
    endcase
    
    assign {reg_write_o, imm_src_o, alu_src_o, mem_write_o, result_src_o, branch_o, alu_op_o, jump_o} = control;

endmodule
