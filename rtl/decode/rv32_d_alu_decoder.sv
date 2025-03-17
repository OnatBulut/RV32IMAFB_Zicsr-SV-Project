`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_d_alu_decoder (input  logic [1:0] alu_op_i,
                           input  logic [31:0] instr_i,
                   
                           output logic [`ALU_CONTROL_WIDTH-1:0] alu_control_o);
                   
    always_comb case (alu_op_i)
        2'b00: alu_control_o = ALU_ADD;                                 // j-type, load, store - add
        2'b01: case (instr_i[14:12])
            3'b000:  alu_control_o = ALU_XOR;                           // beq - xor
            3'b001:  alu_control_o = ALU_XOR;                           // bne - !xor
            3'b100:  alu_control_o = ALU_SLT;                           // blt - slt
            3'b101:  alu_control_o = ALU_SLT;                           // bge - !slt
            3'b110:  alu_control_o = ALU_SLTU;                          // bltu - sltu
            3'b111:  alu_control_o = ALU_SLTU;                          // bgeu - !sltu
            default: alu_control_o = 'bx;
        endcase
        2'b10: casex ({instr_i[5], instr_i[31:25], instr_i[24:20], instr_i[14:12]})
            // instr_i[5] (opcode bit 5) is used to differentiate between R and I type instructions
            
            // RV32I ALU Instructions
            16'b1_0000000_xxxxx_000: alu_control_o = ALU_ADD;                 // add
            16'b0_xxxxxxx_xxxxx_000: alu_control_o = ALU_ADD;                 // addi 
            16'b1_0100000_xxxxx_000: alu_control_o = ALU_SUB;                 // sub
            16'b1_0000000_xxxxx_100: alu_control_o = ALU_XOR;                 // xor
            16'b0_xxxxxxx_xxxxx_100: alu_control_o = ALU_XOR;                 // xori
            16'b1_0000000_xxxxx_110: alu_control_o = ALU_OR;                  // or
            16'b0_xxxxxxx_xxxxx_110: alu_control_o = ALU_OR;                  // ori
            16'b1_0000000_xxxxx_111: alu_control_o = ALU_AND;                 // and
            16'b0_xxxxxxx_xxxxx_111: alu_control_o = ALU_AND;                 // andi
            16'b1_0000000_xxxxx_001: alu_control_o = ALU_SLL;                 // sll
            16'b0_0000000_xxxxx_001: alu_control_o = ALU_SLL;                 // slli
            16'b1_0000000_xxxxx_101: alu_control_o = ALU_SRL;                 // srl
            16'b0_0000000_xxxxx_101: alu_control_o = ALU_SRL;                 // srli
            16'b1_0100000_xxxxx_101: alu_control_o = ALU_SRA;                 // sra
            16'b0_0100000_xxxxx_101: alu_control_o = ALU_SRA;                 // srai
            16'b1_0000000_xxxxx_010: alu_control_o = ALU_SLT;                 // slt
            16'b0_xxxxxxx_xxxxx_010: alu_control_o = ALU_SLT;                 // slti
            16'b1_0000000_xxxxx_011: alu_control_o = ALU_SLTU;                // sltu
            16'b0_xxxxxxx_xxxxx_011: alu_control_o = ALU_SLTU;                // sltiu
            
            // RV32M ALU Instructions
            16'b1_0000001_xxxxx_000: alu_control_o = ALU_MUL;                 // mul
            16'b1_0000001_xxxxx_001: alu_control_o = ALU_MULH;                // mulh
            16'b1_0000001_xxxxx_010: alu_control_o = ALU_MULHSU;              // mulhsu
            16'b1_0000001_xxxxx_011: alu_control_o = ALU_MULHU;               // mulhu
            16'b1_0000001_xxxxx_100: alu_control_o = ALU_DIV;                 // div
            16'b1_0000001_xxxxx_101: alu_control_o = ALU_DIVU;                // divu
            16'b1_0000001_xxxxx_110: alu_control_o = ALU_REM;                 // rem
            16'b1_0000001_xxxxx_111: alu_control_o = ALU_REMU;                // remu
            
            // RV32B ALU Instructions
            16'b1_0100000_xxxxx_111: alu_control_o = ALU_ANDN;                // andn
            16'b1_0100100_xxxxx_001: alu_control_o = ALU_BCLR;                // bclr
            16'b1_0100100_xxxxx_101: alu_control_o = ALU_BEXT;                // bext
            16'b1_0110100_xxxxx_001: alu_control_o = ALU_BINV;                // binv
            16'b1_0010100_xxxxx_001: alu_control_o = ALU_BSET;                // bset
            16'b1_0000101_xxxxx_001: alu_control_o = ALU_CLMUL;               // clmul
            16'b1_0000101_xxxxx_011: alu_control_o = ALU_CLMULH;              // clmulh
            16'b1_0000101_xxxxx_010: alu_control_o = ALU_CLMULR;              // clmulr
            16'b1_0000101_xxxxx_110: alu_control_o = ALU_MAX;                 // max
            16'b1_0000101_xxxxx_111: alu_control_o = ALU_MAXU;                // maxu
            16'b1_0000101_xxxxx_100: alu_control_o = ALU_MIN;                 // min
            16'b1_0000101_xxxxx_101: alu_control_o = ALU_MINU;                // minu
            16'b1_0100000_xxxxx_110: alu_control_o = ALU_ORN;                 // orn
            16'b1_0110000_xxxxx_001: alu_control_o = ALU_ROL;                 // rol
            16'b1_0110000_xxxxx_101: alu_control_o = ALU_ROR;                 // ror
            16'b1_0010000_xxxxx_010: alu_control_o = ALU_SH1ADD;              // sh1add
            16'b1_0010000_xxxxx_100: alu_control_o = ALU_SH2ADD;              // sh2add
            16'b1_0010000_xxxxx_110: alu_control_o = ALU_SH3ADD;              // sh3add
            16'b1_0100000_xxxxx_100: alu_control_o = ALU_XNOR;                // xnor
            16'b1_0000100_xxxxx_100: alu_control_o = ALU_ZEXT_H;              // zext.h
            16'b0_0110000_xxxxx_101: alu_control_o = ALU_ROR;                 // rori
            16'b0_0100100_xxxxx_001: alu_control_o = ALU_BCLR;                // bclri
            16'b0_0100100_xxxxx_101: alu_control_o = ALU_BEXT;                // bexti
            16'b0_0110100_xxxxx_001: alu_control_o = ALU_BINV;                // binvi
            16'b0_0010100_xxxxx_001: alu_control_o = ALU_BSET;                // bseti
            16'b0_0110000_00000_001: alu_control_o = ALU_CLZ;                 // clz
            16'b0_0110000_00010_001: alu_control_o = ALU_CPOP;                // cpop
            16'b0_0110000_00001_001: alu_control_o = ALU_CTZ;                 // ctz
            16'b0_0010100_xxxxx_101: alu_control_o = ALU_ORC_B;               // orc.b
            16'b0_0110100_xxxxx_110: alu_control_o = ALU_REV8;                // rev8
            16'b0_0110000_00100_001: alu_control_o = ALU_SEXT_B;              // sext.b
            16'b0_0110000_00101_001: alu_control_o = ALU_SEXT_H;              // sext.h
            
            default:           alu_control_o = 'bx;
        endcase
        2'b11:   alu_control_o = instr_i[5] ? ALU_PASS : ALU_ADD;             // lui : auipc
        default: alu_control_o = 'bx;
    endcase

endmodule