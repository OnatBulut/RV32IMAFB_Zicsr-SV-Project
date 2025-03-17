`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_e_alu (input  logic [5:0]  alu_control_i,
                   input  logic [31:0] src_a_i, src_b_i,
                 
                   output logic        zero_o,
                   output logic [31:0] result_o);
    
    /*
    // Divider logic
    logic        start, in_progress, done, signed_div;
    logic [`ALU_CONTROL_WIDTH-1:0] active_operation; 
    logic [31:0] quotient, remainder;
    logic [31:0] dividend_reg, divisor_reg;
    
    rv32_e_divider Divider (.clk_i(clk_i),
                            .rst_n_i(rst_n_i),
                            .start_i(start),
                            .signed_i(signed_div),
                            .dividend_i(dividend_reg),
                            .divisor_i(divisor_reg),
                            .done_o(done),
                            .quotient_o(quotient),
                            .remainder_o(remainder));
                                   
    assign stall_cpu_o = in_progress && !done;
                                       
    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (!rst_n_i) begin
            in_progress      <= 1'b0;
            start            <= 1'b0;
            signed_div       <= 1'b0;
            active_operation <= '0;
            dividend_reg     <= 32'b0;
            divisor_reg      <= 32'b0;
        end else begin
            // Handle division completion
            if (done) begin
                in_progress   <= 1'b0;
                start         <= 1'b0;
            end
            
            // Start new division operations
            if (!in_progress && !done) begin
                if (alu_control_i == ALU_DIV || alu_control_i == ALU_REM) begin
                    in_progress      <= 1'b1;
                    start            <= 1'b1;
                    signed_div       <= 1'b1;
                    active_operation <= alu_control_i;
                    dividend_reg     <= src_a_i;
                    divisor_reg      <= src_b_i;
                end else if (alu_control_i == ALU_DIVU || alu_control_i == ALU_REMU) begin
                    in_progress      <= 1'b1;
                    start            <= 1'b1;
                    signed_div       <= 1'b0;
                    active_operation <= alu_control_i;
                    dividend_reg     <= src_a_i;
                    divisor_reg      <= src_b_i;
                end
            end
            
            // Clear start signal after one cycle
            if (start) begin
                start <= 1'b0;
            end
        end
    end*/
    
    always_comb begin
        case (alu_control_i)
            ALU_ADD:    result_o = src_a_i + src_b_i;                                               // ADD
            ALU_SUB:    result_o = src_a_i - src_b_i;                                               // SUB
            ALU_AND:    result_o = src_a_i & src_b_i;                                               // AND
            ALU_OR :    result_o = src_a_i | src_b_i;                                               // OR
            ALU_XOR:    result_o = src_a_i ^ src_b_i;                                               // XOR
            
            ALU_SLT:    result_o = src_a_i[31] == src_b_i[31] ? src_a_i < src_b_i : src_a_i[31];    // SLT
            ALU_SLTU:   result_o = src_a_i < src_b_i;                                               // SLTU
            
            ALU_SLL:    result_o = src_a_i << src_b_i[4:0];                                         // SLL
            ALU_SRL:    result_o = src_a_i >> src_b_i[4:0];                                         // SRL
            ALU_SRA:    result_o = $signed(src_a_i) >>> src_b_i[4:0];                               // SRA
            
            ALU_PASS:   result_o = src_b_i;                                                         // LUI
            
            ALU_ANDN:   result_o = src_a_i & ~src_b_i;
            ALU_BCLR:   result_o = src_a_i & ~(1 << src_b_i[4:0]);  
            ALU_BEXT:   result_o = (src_a_i >> src_b_i[4:0]) & 1;
            ALU_BINV:   result_o = src_a_i ^ (1 << src_b_i[4:0]);
            ALU_BSET:   result_o = src_a_i | (1 << src_b_i[4:0]);
            ALU_CLMUL:  begin
                            result_o = 0;
                            for (int i = 0; i < `XLEN; i++) begin
                                result_o = ((src_b_i >> i) & 1) ? (result_o ^ (src_a_i << i)) : result_o;
                            end
                        end    
            ALU_CLMULH: begin
                            result_o = 0;
                            for (int i = 1; i < `XLEN; i++) begin
                                result_o = ((src_b_i >> i) & 1)? (result_o ^(src_a_i >> (`XLEN - i))) : result_o;         
                            end
                            // todo (src_b_i >> i) & 1 kısmı değişkende tutulup 0. biti kontrol edilebilir.
                        end    
            ALU_CLMULR: begin
                            result_o = 0;
                            for (int i = 0; i < `XLEN; i++) begin
                                result_o = ((src_b_i >> i) & 1) ? (result_o ^ (src_a_i >> (`XLEN - i - 1))) : result_o;         
                            end
                        end    
            ALU_MAX:    result_o = ($signed(src_a_i) < $signed(src_b_i)) ? src_b_i : src_a_i;
                        /*
                        begin
                        if (src_a_i[31] == src_b_i [31]) result_o = (src_a_i < src_b_i) ? src_b_i : src_a_i;
                        else  result_o = (src_a_i[31]) ? src_b_i : src_a_i;     
                        end
                        */
            ALU_MAXU:   result_o = ($unsigned(src_a_i) < $unsigned(src_b_i)) ? src_b_i : src_a_i;
            ALU_MIN:    result_o = ($signed(src_a_i) < $signed(src_b_i)) ? src_a_i : src_b_i;
            ALU_MINU:   result_o = ($unsigned(src_a_i) < $unsigned(src_b_i)) ? src_a_i : src_b_i;
            ALU_ORN:    result_o = src_a_i | (~src_b_i);
            ALU_ROL:    result_o = (src_a_i << src_b_i[4:0]) | (src_a_i >> (`XLEN - src_a_i[4:0]));
            ALU_ROR:    result_o = (src_a_i >> src_b_i[4:0]) | (src_a_i << (`XLEN - src_b_i[4:0]));   
            ALU_SH1ADD: result_o = src_b_i + (src_a_i << 1);
            ALU_SH2ADD: result_o = src_b_i + (src_a_i << 2);
            ALU_SH3ADD: result_o = src_b_i + (src_a_i << 3);
            ALU_XNOR:   result_o = ~(src_a_i ^ src_b_i);
            ALU_ZEXT_H: result_o = {16'b0, src_a_i[15:0]};
            ALU_CLZ:    begin
                            if(src_a_i == 32'b0) begin 
                                result_o = `XLEN;
                            end else if (src_a_i[`XLEN - 1] == 1) begin
                                result_o = 0;
                            end else begin
                                for (int i = (`XLEN - 1); i >= 0; i--) begin
                                    if(src_a_i[i] == 1) begin 
                                        result_o = (`XLEN - 1) - i;
                                        break;
                                    end
                                end
                            end
                        end
                        
            ALU_CPOP:   
                        /*
                        result_o = (`XLEN - 1) - (src_a_i ? $clog2(src_a_i) : -1);
                        */
                        begin
                            result_o = 0;
                            for(int i = 0; i < `XLEN; i++) begin
                                if(src_a_i[i] == 1) begin
                                    result_o = result_o + 1;
                                end
                            end
                        end
                       
            ALU_CTZ:    begin
                            if(src_a_i == 32'b0) begin
                                result_o = `XLEN;
                            end else if(src_a_i[0] == 1) begin
                                result_o = 0;
                            end else begin
                                for(int i = 0; i < `XLEN; i++) begin
                                    if(src_a_i[i] == 1) begin
                                        result_o = i;
                                        break;
                                    end
                                end
                            end
                        end
                       
            ALU_ORC_B:  begin
                            result_o = 0;
                            for (int i = 0; i < `XLEN; i = i + 8) begin
                                if (src_a_i[i +: 8] == 8'b00000000) begin
                                    result_o[i +: 8] = 8'b00000000;
                                end else begin
                                    result_o[i +: 8] = 8'b11111111;
                                end
                            end
                        end 

            ALU_REV8:   begin
                            result_o = 0;
                            for (int i = 0, j = `XLEN - 1; i < `XLEN; i = i + 8, j = j - 8) begin
                                result_o[i +: 8] = src_a_i[j -: 8];  //result_o[i+7:i] = src_a_i[j-7:j];
                            end
                        end
                        
            ALU_SEXT_B: result_o = {{(`XLEN - 8){src_a_i[7]}}, src_a_i[7:0]};
            ALU_SEXT_H: result_o = {{(`XLEN - 16){src_a_i[15]}}, src_a_i[15:0]};
            
            default:    result_o = 'bx;                                                             // Invalid operation
        endcase
    end
    
    assign zero_o = (result_o == 0);

endmodule
