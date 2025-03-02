`timescale 1ns / 1ps

module alu_decoder(input  logic       opb5_i, funct7b5_i,
                   input  logic [1:0] alu_op_i,
                   input  logic [2:0] funct3_i,
                   
                   output logic [3:0] alu_control_o);
                   
    always_comb case(alu_op_i)
        2'b00: alu_control_o = 4'b0000;                                           // j-type, load, store - add
        2'b01: case (funct3_i)
            3'b000:  alu_control_o = 4'b0100;                                     // beq - xor
            3'b001:  alu_control_o = 4'b0100;                                     // bne - !xor
            3'b100:  alu_control_o = 4'b0101;                                     // blt - slt
            3'b101:  alu_control_o = 4'b0101;                                     // bge - !slt
            3'b110:  alu_control_o = 4'b0110;                                     // bltu - sltu
            3'b111:  alu_control_o = 4'b0110;                                     // bgeu - !sltu
            default: alu_control_o = 4'bx;
        endcase
        2'b10: case (funct3_i)
            3'b000:  alu_control_o = (opb5_i & funct7b5_i) ? 4'b0001 : 4'b0000;   // sub : add
            3'b001:  alu_control_o = 4'b0111;                                     // sll
            3'b010:  alu_control_o = 4'b0101;                                     // slt
            3'b011:  alu_control_o = 4'b0110;                                     // sltu
            3'b100:  alu_control_o = 4'b0100;                                     // xor
            3'b101:  alu_control_o = funct7b5_i ? 4'b1001 : 4'b0100;              // sra : srl
            3'b110:  alu_control_o = 4'b0011;                                     // or
            3'b111:  alu_control_o = 4'b0010;                                     // and
            default: alu_control_o = 4'bx;
        endcase
        2'b11: alu_control_o = opb5_i ? 4'b1010 : 4'b1011;                        // lui : auipc
        default: alu_control_o = 4'bx;
    endcase

endmodule