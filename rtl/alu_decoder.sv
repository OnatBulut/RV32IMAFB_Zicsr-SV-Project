`timescale 1ns / 1ps
`include "defines_header.svh"

module alu_decoder(input  logic       opb5_i,
                   input  logic [1:0] alu_op_i,
                   input  logic [2:0] funct3_i,
                   input  logic [6:0] funct7_i,
                   
                   output logic [`ALU_CONTROL_SIZE-1:0] alu_control_o);
                   
    always_comb case(alu_op_i)
        2'b00: alu_control_o = ALU_ADD;                                            // j-type, load, store - add
        2'b01: case (funct3_i)
            3'b000:  alu_control_o = ALU_XOR;                                      // beq - xor
            3'b001:  alu_control_o = ALU_XOR;                                      // bne - !xor
            3'b100:  alu_control_o = ALU_SLT;                                      // blt - slt
            3'b101:  alu_control_o = ALU_SLT;                                      // bge - !slt
            3'b110:  alu_control_o = ALU_SLTU;                                     // bltu - sltu
            3'b111:  alu_control_o = ALU_SLTU;                                     // bgeu - !sltu
            default: alu_control_o = 'bx;
        endcase
        2'b10: case ({opb5_i, funct3_i}) // opb5_i is used to differentiate between R and I type instructions 
            4'b1_000: case ({funct7_i[5], funct7_i[0]})
                2'b0_0:   alu_control_o = ALU_ADD;                                 // add 
                2'b1_0:   alu_control_o = ALU_SUB;                                 // sub
                2'b0_1:   alu_control_o = ALU_MUL;                                 // mul
                default: alu_control_o = 'bx;
            endcase
            4'b0_000: alu_control_o = ALU_ADD;                                     // addi
            4'b1_001: alu_control_o = funct7_i[0] ? ALU_MULH : ALU_SLL;            // mulh : sll
            4'b0_001: alu_control_o = ALU_SLL;                                     // slli
            4'b1_010: alu_control_o = funct7_i[0] ? ALU_MULHSU : ALU_SLT;          // mulhsu : slt
            4'b0_010: alu_control_o = ALU_SLT;                                     // slti
            4'b1_011: alu_control_o = funct7_i[0] ? ALU_MULHU : ALU_SLTU;          // mulhu : sltu
            4'b0_011: alu_control_o = ALU_SLTU;                                    // sltui
            4'b1_100: alu_control_o = funct7_i[0] ? ALU_DIV : ALU_XOR;             // div : xor
            4'b0_100: alu_control_o = ALU_XOR;                                     // xori
            4'b1_101: case ({funct7_i[5], funct7_i[0]})
                2'b0_0:  alu_control_o = ALU_SRL;                                  // srl
                2'b1_0:  alu_control_o = ALU_SRA;                                  // sra
                2'b0_1:  alu_control_o = ALU_DIVU;                                 // divu
                default: alu_control_o = 'bx;
            endcase
            4'b0_101:  alu_control_o = funct7_i[5] ? ALU_SRA : ALU_SRL;            // srai : srli
            4'b1_110:  alu_control_o = funct7_i[0] ? ALU_REM : ALU_OR;             // rem : or
            4'b0_110:  alu_control_o = ALU_OR;                                     // ori
            4'b1_111:  alu_control_o = funct7_i[0] ? ALU_REMU : ALU_AND;           // remu : and
            4'b0_111:  alu_control_o = ALU_AND;                                    // andi
            default: alu_control_o = 'bx;
        endcase
        2'b11: alu_control_o = opb5_i ? ALU_LUI : ALU_AUIPC;                       // lui : auipc
        default: alu_control_o = 'bx;
    endcase

endmodule