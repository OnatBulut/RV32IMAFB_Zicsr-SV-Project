`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_d_alu_decoder (input  logic [1:0]  alu_op_i,
                           input  logic [31:0] instr_i,

                           output logic        valid_op_o,
                           output logic [`ALU_CONTROL_WIDTH-1:0] alu_control_o);
                   
    always_comb case (alu_op_i)
        2'b00: begin alu_control_o = ALU_ADD; valid_op_o = 1'b1; end                                        // j-type, load, store - add
        2'b01: case (instr_i[14:12])
            3'b000:  begin alu_control_o = ALU_XOR;  valid_op_o = 1'b1; end                                 // beq - xor
            3'b001:  begin alu_control_o = ALU_XOR;  valid_op_o = 1'b1; end                                 // bne - !xor
            3'b100:  begin alu_control_o = ALU_SLT;  valid_op_o = 1'b1; end                                 // blt - slt
            3'b101:  begin alu_control_o = ALU_SLT;  valid_op_o = 1'b1; end                                 // bge - !slt
            3'b110:  begin alu_control_o = ALU_SLTU; valid_op_o = 1'b1; end                                 // bltu - sltu
            3'b111:  begin alu_control_o = ALU_SLTU; valid_op_o = 1'b1; end                                 // bgeu - !sltu
            default: begin alu_control_o = 'bx;      valid_op_o = 1'b0; end
        endcase
        2'b10: casex ({instr_i[5], instr_i[31:25], instr_i[24:20], instr_i[14:12]})
            // instr_i[5] (opcode bit 5) is used to differentiate between R and I type instructions
            
            // RV32I ALU Instructions
            16'b1_0000000_xxxxx_000: begin alu_control_o = ALU_ADD;    valid_op_o = 1'b1; end               // add
            16'b0_xxxxxxx_xxxxx_000: begin alu_control_o = ALU_ADD;    valid_op_o = 1'b1; end               // addi 
            16'b1_0100000_xxxxx_000: begin alu_control_o = ALU_SUB;    valid_op_o = 1'b1; end               // sub
            16'b1_0000000_xxxxx_100: begin alu_control_o = ALU_XOR;    valid_op_o = 1'b1; end               // xor
            16'b0_xxxxxxx_xxxxx_100: begin alu_control_o = ALU_XOR;    valid_op_o = 1'b1; end               // xori
            16'b1_0000000_xxxxx_110: begin alu_control_o = ALU_OR;     valid_op_o = 1'b1; end               // or
            16'b0_xxxxxxx_xxxxx_110: begin alu_control_o = ALU_OR;     valid_op_o = 1'b1; end               // ori
            16'b1_0000000_xxxxx_111: begin alu_control_o = ALU_AND;    valid_op_o = 1'b1; end               // and
            16'b0_xxxxxxx_xxxxx_111: begin alu_control_o = ALU_AND;    valid_op_o = 1'b1; end               // andi
            16'b1_0000000_xxxxx_001: begin alu_control_o = ALU_SLL;    valid_op_o = 1'b1; end               // sll
            16'b0_0000000_xxxxx_001: begin alu_control_o = ALU_SLL;    valid_op_o = 1'b1; end               // slli
            16'b1_0000000_xxxxx_101: begin alu_control_o = ALU_SRL;    valid_op_o = 1'b1; end               // srl
            16'b0_0000000_xxxxx_101: begin alu_control_o = ALU_SRL;    valid_op_o = 1'b1; end               // srli
            16'b1_0100000_xxxxx_101: begin alu_control_o = ALU_SRA;    valid_op_o = 1'b1; end               // sra
            16'b0_0100000_xxxxx_101: begin alu_control_o = ALU_SRA;    valid_op_o = 1'b1; end               // srai
            16'b1_0000000_xxxxx_010: begin alu_control_o = ALU_SLT;    valid_op_o = 1'b1; end               // slt
            16'b0_xxxxxxx_xxxxx_010: begin alu_control_o = ALU_SLT;    valid_op_o = 1'b1; end               // slti
            16'b1_0000000_xxxxx_011: begin alu_control_o = ALU_SLTU;   valid_op_o = 1'b1; end               // sltu
            16'b0_xxxxxxx_xxxxx_011: begin alu_control_o = ALU_SLTU;   valid_op_o = 1'b1; end               // sltiu
            
            // RV32M ALU Instructions
            16'b1_0000001_xxxxx_000: begin alu_control_o = ALU_MUL;    valid_op_o = 1'b1; end               // mul
            16'b1_0000001_xxxxx_001: begin alu_control_o = ALU_MULH;   valid_op_o = 1'b1; end               // mulh
            16'b1_0000001_xxxxx_010: begin alu_control_o = ALU_MULHSU; valid_op_o = 1'b1; end               // mulhsu
            16'b1_0000001_xxxxx_011: begin alu_control_o = ALU_MULHU;  valid_op_o = 1'b1; end               // mulhu
            16'b1_0000001_xxxxx_100: begin alu_control_o = ALU_DIV;    valid_op_o = 1'b1; end               // div
            16'b1_0000001_xxxxx_101: begin alu_control_o = ALU_DIVU;   valid_op_o = 1'b1; end               // divu
            16'b1_0000001_xxxxx_110: begin alu_control_o = ALU_REM;    valid_op_o = 1'b1; end               // rem
            16'b1_0000001_xxxxx_111: begin alu_control_o = ALU_REMU;   valid_op_o = 1'b1; end               // remu
            
            // RV32B ALU Instructions
            16'b1_0100000_xxxxx_111: begin alu_control_o = ALU_ANDN;   valid_op_o = 1'b1; end               // andn
            16'b1_0100100_xxxxx_001: begin alu_control_o = ALU_BCLR;   valid_op_o = 1'b1; end               // bclr
            16'b1_0100100_xxxxx_101: begin alu_control_o = ALU_BEXT;   valid_op_o = 1'b1; end               // bext
            16'b1_0110100_xxxxx_001: begin alu_control_o = ALU_BINV;   valid_op_o = 1'b1; end               // binv
            16'b1_0010100_xxxxx_001: begin alu_control_o = ALU_BSET;   valid_op_o = 1'b1; end               // bset
            16'b1_0000101_xxxxx_001: begin alu_control_o = ALU_CLMUL;  valid_op_o = 1'b1; end               // clmul
            16'b1_0000101_xxxxx_011: begin alu_control_o = ALU_CLMULH; valid_op_o = 1'b1; end               // clmulh
            16'b1_0000101_xxxxx_010: begin alu_control_o = ALU_CLMULR; valid_op_o = 1'b1; end               // clmulr
            16'b1_0000101_xxxxx_110: begin alu_control_o = ALU_MAX;    valid_op_o = 1'b1; end               // max
            16'b1_0000101_xxxxx_111: begin alu_control_o = ALU_MAXU;   valid_op_o = 1'b1; end               // maxu
            16'b1_0000101_xxxxx_100: begin alu_control_o = ALU_MIN;    valid_op_o = 1'b1; end               // min
            16'b1_0000101_xxxxx_101: begin alu_control_o = ALU_MINU;   valid_op_o = 1'b1; end               // minu
            16'b1_0100000_xxxxx_110: begin alu_control_o = ALU_ORN;    valid_op_o = 1'b1; end               // orn
            16'b1_0110000_xxxxx_001: begin alu_control_o = ALU_ROL;    valid_op_o = 1'b1; end               // rol
            16'b1_0110000_xxxxx_101: begin alu_control_o = ALU_ROR;    valid_op_o = 1'b1; end               // ror
            16'b1_0010000_xxxxx_010: begin alu_control_o = ALU_SH1ADD; valid_op_o = 1'b1; end               // sh1add
            16'b1_0010000_xxxxx_100: begin alu_control_o = ALU_SH2ADD; valid_op_o = 1'b1; end               // sh2add
            16'b1_0010000_xxxxx_110: begin alu_control_o = ALU_SH3ADD; valid_op_o = 1'b1; end               // sh3add
            16'b1_0100000_xxxxx_100: begin alu_control_o = ALU_XNOR;   valid_op_o = 1'b1; end               // xnor
            16'b1_0000100_xxxxx_100: begin alu_control_o = ALU_ZEXT_H; valid_op_o = 1'b1; end               // zext.h
            16'b0_0110000_xxxxx_101: begin alu_control_o = ALU_ROR;    valid_op_o = 1'b1; end               // rori
            16'b0_0100100_xxxxx_001: begin alu_control_o = ALU_BCLR;   valid_op_o = 1'b1; end               // bclri
            16'b0_0100100_xxxxx_101: begin alu_control_o = ALU_BEXT;   valid_op_o = 1'b1; end               // bexti
            16'b0_0110100_xxxxx_001: begin alu_control_o = ALU_BINV;   valid_op_o = 1'b1; end               // binvi
            16'b0_0010100_xxxxx_001: begin alu_control_o = ALU_BSET;   valid_op_o = 1'b1; end               // bseti
            16'b0_0110000_00000_001: begin alu_control_o = ALU_CLZ;    valid_op_o = 1'b1; end               // clz
            16'b0_0110000_00010_001: begin alu_control_o = ALU_CPOP;   valid_op_o = 1'b1; end               // cpop
            16'b0_0110000_00001_001: begin alu_control_o = ALU_CTZ;    valid_op_o = 1'b1; end               // ctz
            16'b0_0010100_xxxxx_101: begin alu_control_o = ALU_ORC_B;  valid_op_o = 1'b1; end               // orc.b
            16'b0_0110100_xxxxx_110: begin alu_control_o = ALU_REV8;   valid_op_o = 1'b1; end               // rev8
            16'b0_0110000_00100_001: begin alu_control_o = ALU_SEXT_B; valid_op_o = 1'b1; end               // sext.b
            16'b0_0110000_00101_001: begin alu_control_o = ALU_SEXT_H; valid_op_o = 1'b1; end               // sext.h
            
            default:                 begin alu_control_o = 'bx;        valid_op_o = 1'b0; end
        endcase
        2'b11:   begin alu_control_o = instr_i[5] ? ALU_PASS : ALU_ADD; valid_op_o = 1'b1; end              // lui : auipc
        default: begin alu_control_o = 'bx; valid_op_o = 1'b0; end
    endcase

endmodule