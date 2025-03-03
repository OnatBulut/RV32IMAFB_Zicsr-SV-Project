`timescale 1ns / 1ps

module extend(input  logic [2:0]  imm_src_i,
              input  logic [31:7] instr_i,

              output logic [31:0] imm_ext_o);
    
    always_comb case(imm_src_i)
        3'b000:   imm_ext_o = {{20{instr_i[31]}}, instr_i[31:20]};                                                   // I-Type
        3'b001:   imm_ext_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};                                    // S-Type
        3'b010:   imm_ext_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};     // B-Type
        3'b011:   imm_ext_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};                // J-Type
        3'b100:   imm_ext_o = {instr_i[31:12], 12'b0};                                                               // U-Type
        default: imm_ext_o = 32'bx;
    endcase
    
endmodule