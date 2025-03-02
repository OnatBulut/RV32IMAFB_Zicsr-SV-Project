`timescale 1ns / 1ps

module alu(input  logic [3:0]  alu_control_i,
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
            4'b0000,                                                                             // ADD
            4'b0001:  result_o = sum[31:0];                                                      // SUB
            4'b0010:  result_o = src_a_i & src_b_i;                                              // AND
            4'b0011:  result_o = src_a_i | src_b_i;                                              // OR
            4'b0100:  result_o = src_a_i ^ src_b_i;                                              // XOR
            
            4'b0101:  result_o = src_a_i[31] == src_b_i[31] ? src_a_i < src_b_i : src_a_i[31];   // SLT
            4'b0110:  result_o = src_a_i < src_b_i;                                              // SLTU
            4'b0111:  result_o = src_a_i << src_b_i;                                             // SLL
            4'b1000:  result_o = src_a_i >> src_b_i;                                             // SRL
            4'b1001:  result_o = src_a_i >>> src_b_i;                                            // SRA
            
            4'b1010:  result_o = src_b_i;                                                        // LUI
            4'b1011:  result_o = src_a_i + src_b_i;                                              // AUIPC
            // possibly remove lui from alu and forward it directly
            
            default: result_o = 'bx;                                                             // Invalid operation
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