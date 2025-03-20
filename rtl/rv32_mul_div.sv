`timescale 1ns / 1ps
`include "defines_header.svh"

// Starting a division:
// - Division Unit stores the division instruction and starts the division using the values from the regfile
// - Division Unit outputs the in progress signal and the relevant instruction data
// - Hazard Unit checks if the next instruction requires the result of the division
//      - If the result is required, pipeline before the Execute Stage gets stalled until the division is done
//      - If another instruction writes to the destination of the divider before it is used, stop division and discard result
// - When Division Unit sends the done signal, stall the pipeline before the Execute Stage and wait a cycle,
//   populate the Execute/Memory pipe with relevant data and control signals of the division instruction.
// New hazards may occur but they may already be handled by the hazard unit, check instructions that needs the division result after a few cycles have passed

// TODO: Implement signed division, possibly add a LUT for division with powers of 2 and prevent division with 0 and overflow.
// For signed division, twos complement of the input can be taken if its sign bit is 1 and signed_i is 1. Overflow may occur.
// Check if the output is going to have a negative sign (if dividend_i or divisor_i is negative).
// Don't waste time if any of the two inputs is 0. Not sure about overflow.

module rv32_mul_div (input  logic        clk_i, rst_n_i,
                     input  logic [`ALU_CONTROL_WIDTH-1:0] alu_control_i,
                     input  logic [31:0] read_data_1_i, read_data_2_i,

                     output logic        running_o, done_o,
                     output logic [31:0] result_o);
    
    // Controller
    logic        start;
    
    logic        input_1_sign;
    logic        input_2_sign;
    
    logic [31:0] input_1_reg;
    logic [31:0] input_2_reg;
    
    logic [31:0] high_result, low_result;
    logic [31:0] quotient, remainder;
    
    always_comb begin : controller
        case (alu_control_i)
            // Lower 32-Bit Signed Multiplication
            ALU_MUL:    begin
                            input_1_sign = read_data_1_i[31];
                            input_2_sign = read_data_2_i[31];
                            
                            input_1_reg = input_1_sign ? ~read_data_1_i + 1 : read_data_1_i;
                            input_2_reg = input_2_sign ? ~read_data_2_i + 1 : read_data_2_i;
                            
                            result_o = input_1_sign != input_2_sign ? ~low_result + 1 : low_result;
                            
                            start = 1'b1;
                        end
            // Higher 32-Bit Signed Multiplication
            ALU_MULH:   begin
                            input_1_sign = read_data_1_i[31];
                            input_2_sign = read_data_2_i[31];
                            
                            input_1_reg = input_1_sign ? ~read_data_1_i + 1 : read_data_1_i;
                            input_2_reg = input_2_sign ? ~read_data_2_i + 1 : read_data_2_i;
                            
                            result_o = input_1_sign != input_2_sign ? ~high_result + 1 : high_result;
                            
                            start = 1'b1;
                        end
            // Higher 32-Bit Signed-Unsigned Multiplication
            ALU_MULHSU: begin
                            input_1_sign = read_data_1_i[31];
                            
                            input_1_reg = input_1_sign ? ~read_data_1_i + 1 : read_data_1_i;
                            input_2_reg = read_data_2_i;
                            
                            result_o = input_1_sign ? ~high_result + 1 : high_result;
                        
                            start = 1'b1;
                        end
            // Higher 32-Bit Unsigned Multiplication
            ALU_MULHU:  begin
                            input_1_reg = read_data_1_i;
                            input_2_reg = read_data_2_i;
                            
                            result_o = high_result;
                            
                            start = 1'b1;
                        end
            // 32-Bit Signed Division
            ALU_DIV:    begin
                            input_1_sign = read_data_1_i[31];
                            input_2_sign = read_data_2_i[31];
                            
                            input_1_reg = input_1_sign ? ~read_data_1_i + 1 : read_data_1_i;
                            input_2_reg = input_2_sign ? ~read_data_2_i + 1 : read_data_2_i;
                            
                            result_o = input_1_sign != input_2_sign ? ~quotient + 1 : quotient;
                            
                            start = 1'b1;
                        end
            // 32-Bit Unsigned Division
            ALU_DIVU:   begin
                            input_1_reg = read_data_1_i;
                            input_2_reg = read_data_2_i;
                            
                            result_o = quotient;
                            
                            start = 1'b1;
                        end
            // 32-Bit Signed Remainder
            ALU_REM:    begin
                            input_1_sign = read_data_1_i[31];
                            input_2_sign = read_data_2_i[31];
                            
                            input_1_reg = input_1_sign ? ~read_data_1_i + 1 : read_data_1_i;
                            input_2_reg = input_2_sign ? ~read_data_2_i + 1 : read_data_2_i;
                            
                            result_o = input_1_sign ? ~remainder + 1 : remainder; // Remainder Sign = Dividend Sign
                            
                            start = 1'b1;
                        end
            // 32-Bit Unsigned Remainder
            ALU_REMU:   begin
                            input_1_reg = read_data_1_i;
                            input_2_reg = read_data_2_i;
                            
                            result_o = remainder;
                            
                            start = 1'b1;
                        end
            // Unrelated Operation
            default:    begin
                            input_1_reg = 32'b0;
                            input_2_reg = 32'b1;
                            
                            result_o = 32'b0;
                            
                            start = 1'b0;
                        end 
        endcase
    end
                     
    // Multiplication
    
    // Division
    
    typedef enum logic [1:0] { IDLE, DIVIDE, FINISH } div_state_t;
    div_state_t div_state, div_next_state;

    logic [5:0]  count;
    logic [31:0] Q, Q_next;
    logic [63:0] R, R_next, D;
    
    always_ff @(posedge clk_i or negedge rst_n_i) begin : division_ff
        if (!rst_n_i) begin
            div_state <= IDLE;
            Q <= 0;
            R <= 0;
            D <= 0;
            count <= 0;
            running_o <= 1'b0;
        end else begin
            div_state <= div_next_state;
            Q <= Q_next;
            R <= R_next;
            
            if (div_state == IDLE && start) begin
                count <= 31;
                running_o <= 1'b1;
                D <= {read_data_1_i, 32'b0};
                R <= {32'b0, read_data_2_i};
            end else if (div_state == DIVIDE) begin
                count <= count - 1'b1;
            end
            
            if (done_o) begin
                running_o <= 1'b0;
            end
        end
    end

    always_comb begin : division_comb
        div_next_state = div_state;
        Q_next = Q;
        R_next = R;
        
        done_o = 1'b0;
        quotient = 32'b0;
        remainder = 32'b0;
        
        case (div_state)
            IDLE: begin
                if (start) begin
                    Q_next = 0;
                    div_next_state = DIVIDE;
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
                    div_next_state = FINISH;
            end

            FINISH: begin
                Q_next = Q - ~Q;
                
                if (R[63]) begin
                    R_next = R + D;
                    Q_next = Q_next - 1;
                end
                
                quotient = Q_next;
                remainder = R_next[63:32];
              	
              	done_o = 1'b1;
                div_next_state = IDLE;
            end
        endcase
    end
  
endmodule
