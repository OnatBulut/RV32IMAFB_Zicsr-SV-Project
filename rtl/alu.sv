`timescale 1ns / 1ps

module alu(input  logic [2:0]  alu_control_i,
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
            3'b000,                                                                             // ADD
            3'b001:  result_o = sum[31:0];                                                      // SUB
            3'b010:  result_o = src_a_i & src_b_i;                                              // AND
            3'b011:  result_o = src_a_i | src_b_i;                                              // OR
            3'b100:  result_o = src_a_i ^ src_b_i;                                              // XOR
            
            3'b101:  result_o = src_a_i[31] == src_b_i[31] ? src_a_i < src_b_i : src_a_i[31];   // SLT
            3'b110:  result_o = src_a_i < src_b_i;                                              // SLTU
            3'b111:  result_o = src_a_i << src_b_i;                                             // SLLs
            
            default: result_o = 'bx;                                                            // Invalid operation
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