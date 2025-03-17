`timescale 1ns / 1ps

// TODO: Implement signed division, possibly add a LUT for division with powers of 2 and prevent division with 0 and overflow.
// For signed division, twos complement of the input can be taken if its sign bit is 1 and signed_i is 1. Overflow may occur.
// Check if the output is going to have a negative sign (if dividend_i or divisor_i is negative).
// Don't waste time if any of the two inputs is 0. Not sure about overflow.

module rv32_e_divider (input  logic        clk_i, rst_n_i, start_i, signed_i,
                       input  logic [31:0] dividend_i, divisor_i,

                       output logic        done_o,
                       output logic [31:0] quotient_o, remainder_o);
    
    typedef enum logic [1:0] { IDLE, DIVIDE, FINISH } state_t;
    state_t state, next_state;

    logic [31:0] Q, Q_next;
    logic [5:0]  count;
    logic [63:0] R, R_next, D;
    
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
            Q <= 0;
            R <= 0;
            D <= 0;
            count <= 0;
        end else begin
            state <= next_state;
            Q <= Q_next;
            R <= R_next;
            
            if (state == IDLE && start_i) begin
                count <= 31;
                D <= {divisor_i, 32'b0};
                R <= {32'b0, dividend_i};
            end else if (state == DIVIDE) begin
                count <= count - 1'b1;
            end 
        end
    end

    always_comb begin
        next_state = state;
        Q_next = Q;
        R_next = R;
        
        done_o = 1'b0;
        quotient_o = 32'b0;
        remainder_o = 32'b0;
        
        case (state)
            IDLE: begin
                if (start_i) begin
                    Q_next = 0;
                    next_state = DIVIDE;
                end
            end
            
            DIVIDE: begin              
                if (R[63]) begin
                    R_next = (R << 1) + D;
                    Q_next = Q;
                end else begin
                    R_next = (R << 1) - D;
                    Q_next = Q | (1 << count);
                end
                
              	if (count == 0)
                    next_state = FINISH;
            end

            FINISH: begin
                Q_next = Q - ~Q;
                
                if (R[63]) begin
                    R_next = R + D;
                    Q_next = Q_next - 1;
                end
                
                quotient_o = Q_next;
                remainder_o = {32'b0, R_next[63:32]};
              	
              	done_o = 1'b1;
                next_state = IDLE;
            end
        endcase
    end
  
endmodule
