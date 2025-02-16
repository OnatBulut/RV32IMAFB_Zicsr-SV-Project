`timescale 1ns / 1ps

module alu_decoder(input  logic       opb5_i, funct7b5_i,
                   input  logic [1:0] alu_op_i,
                   input  logic [2:0] funct3_i,
                   
                   output logic [2:0] alu_control_o);
                   
    always_comb case(alu_op_i)
        2'b00: alu_control_o = 3'b000;  // lw, sw - add
        2'b01: alu_control_o = 3'b001;  // beq - add
        2'b10: case (funct3_i)
            3'b000:  alu_control_o = (opb5_i & funct7b5_i) ? 3'b001 : 3'b000;   // sub : add
            3'b001:  alu_control_o = 3'b111;                                    // sll
            3'b010:  alu_control_o = 3'b101;                                    // slt
            3'b011:  alu_control_o = 3'b110;                                    // sltu
            3'b110:  alu_control_o = 3'b011;                                    // or
            3'b111:  alu_control_o = 3'b010;                                    // and
            default: alu_control_o = 3'bx;
        endcase
        default: alu_control_o = 3'bx;
    endcase

endmodule