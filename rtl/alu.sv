`timescale 1ns / 1ps
`include "defines_header.svh"

module alu(input  logic [`ALU_CONTROL_SIZE-1:0] alu_control_i,
           input  logic [31:0] src_a_i, src_b_i,
           
           output logic        zero_o,
           //output logic [3:0]  alu_flags_o,   // NZCV
           output logic [31:0] result_o);
    
    logic [32:0] sum; // 33 Bit Sum value to hold carry/borrow out
    
    // Control whether addition or subtraction is being done
    // + convert carry in to borrow in accordingly
    assign sum = src_a_i + (alu_control_i[0] ? ~src_b_i : src_b_i) + alu_control_i[0];
    
    always_comb begin
        case (alu_control_i)
            ALU_ADD,                                                                              // ADD
            ALU_SUB:   result_o = sum[31:0];                                                      // SUB
            ALU_AND:   result_o = src_a_i & src_b_i;                                              // AND
            ALU_OR :   result_o = src_a_i | src_b_i;                                              // OR
            ALU_XOR:   result_o = src_a_i ^ src_b_i;                                              // XOR
            
            ALU_SLT:   result_o = src_a_i[31] == src_b_i[31] ? src_a_i < src_b_i : src_a_i[31];   // SLT
            ALU_SLTU:  result_o = src_a_i < src_b_i;                                              // SLTU
            ALU_SLL:   result_o = src_a_i << src_b_i;                                             // SLL
            ALU_SRL:   result_o = src_a_i >> src_b_i;                                             // SRL
            ALU_SRA:   result_o = src_a_i >>> src_b_i;                                            // SRA
            
            ALU_LUI:   result_o = src_b_i;                                                        // LUI
            ALU_AUIPC: result_o = src_a_i + src_b_i;                                              // AUIPC
            // possibly remove lui from alu and forward it directly
            
            default:   result_o = 'bx;                                                            // Invalid operation
        endcase
        
        zero_o = (result_o == 0);
        
        /*
        alu_flags[0] = ~(alu_control_i[0] ^ src_a_i[31] ^ src_b_i[31]) & (src_a_i[31] ^ sum[31]) & ~alu_control_i[1];   // V
        alu_flags[1] = ~alu_control_i[1] & sum[32];                                                                     // C
        alu_flags[2] = (result_o == 0);                                                                                 // Z
        alu_flags[3] = result_o[31];                                                                                    // N
        */
    end	
				
endmodule