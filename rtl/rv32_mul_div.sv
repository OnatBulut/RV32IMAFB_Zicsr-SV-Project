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

// TODO: prevent division with 0 and overflow.
// Don't waste time if any of the two inputs is 0. Not sure about overflow.

module rv32_mul_div (input  logic        clk_i, rst_n_i, flush_i,
                     input  logic [`ALU_CONTROL_WIDTH-1:0] alu_control_i,
                     input  logic [31:0] read_data_1_i, read_data_2_i,
                     input  logic [31:0] instr_i,

                     output logic        running_o, done_o,
                     output logic [31:0] result_o, instr_o);
    
    typedef enum logic [1:0] { IDLE, RUNNING_MUL, RUNNING_DIV } state_t;
    state_t state;
    
    typedef enum logic [1:0] { DIV_IDLE, DIVIDE, DIV_FINISH } div_state_t;
    div_state_t div_state, div_next_state;
    
    logic        input_1_sign, input_2_sign;
    logic [31:0] input_1_reg, input_2_reg;
    logic [`ALU_CONTROL_WIDTH-1:0] operation_reg;
    
    logic [31:0] high_result, low_result;
    logic [31:0] quotient, remainder;
    
    logic [4:0]  count;
    logic [31:0] Q, Q_next;
    logic [63:0] R, R_next, D;
    
    logic        div_start, div_done;
    logic        mul_start, mul_done;
    
    always_ff @(posedge clk_i or negedge rst_n_i) begin : contoller_fsm
        if (!rst_n_i || flush_i) begin
            state         <= IDLE;
            running_o     <= 1'b0;
            input_1_reg   <= 32'b0;
            input_2_reg   <= 32'b0;
            instr_o       <= 32'b0;
            operation_reg <= 'b0;
            input_1_sign  <= 1'b0;
            input_2_sign  <= 1'b0;
            div_start     <= 1'b0;
            mul_start     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (alu_control_i inside { ALU_MUL, ALU_MULH, ALU_MULHSU, ALU_MULHU, ALU_DIV, ALU_DIVU, ALU_REM, ALU_REMU }) begin
                        
                        operation_reg <= alu_control_i;
                        instr_o       <= instr_i;
                        
                        case (alu_control_i)
                            ALU_MUL, ALU_MULH, ALU_DIV, ALU_REM: begin
                                input_1_sign <= read_data_1_i[31];
                                input_2_sign <= read_data_2_i[31];
                                
                                input_1_reg  <= read_data_1_i[31] ? ~read_data_1_i + 1 : read_data_1_i;
                                input_2_reg  <= read_data_2_i[31] ? ~read_data_2_i + 1 : read_data_2_i;
                            end
                            
                            ALU_MULHSU: begin
                                input_1_sign <= read_data_1_i[31];
                                input_2_sign <= 1'b0;
                                
                                input_1_reg  <= read_data_1_i[31] ? ~read_data_1_i + 1 : read_data_1_i;
                                input_2_reg  <= read_data_2_i;
                            end
                            
                            ALU_MULHU, ALU_DIVU, ALU_REMU: begin
                                input_1_sign <= 1'b0;
                                input_2_sign <= 1'b0;
                                
                                input_1_reg  <= read_data_1_i;
                                input_2_reg  <= read_data_2_i;
                            end
                        endcase
                        
                        if (alu_control_i inside { ALU_MUL, ALU_MULH, ALU_MULHSU, ALU_MULHU }) begin
                            state     <= RUNNING_MUL;
                            mul_start <= 1'b1;
                        end else begin
                            state     <= RUNNING_DIV;
                            div_start <= 1'b1;
                        end
                        
                        running_o <= 1'b1;
                    end
                end
                
                RUNNING_MUL: begin
                    mul_start <= 1'b0;
                    
                    if (mul_done) begin
                        state     <= IDLE;
                        running_o <= 1'b0;
                    end
                end
                
                RUNNING_DIV: begin
                    div_start <= 1'b0;
                    
                    if (div_done) begin
                        state     <= IDLE;
                        running_o <= 1'b0;
                    end
                end
            endcase
        end
    end

    always_comb begin : controller_logic
        case (operation_reg)
            ALU_MUL: 
                result_o = input_1_sign != input_2_sign ? ~low_result + 1 : low_result;
            
            ALU_MULH:
                result_o = input_1_sign != input_2_sign ? ~high_result + 1 : high_result;
                
            ALU_MULHSU:
                result_o = input_1_sign ? ~high_result + 1 : high_result;
                
            ALU_MULHU:
                result_o = high_result;
                
            ALU_DIV:
                result_o = input_1_sign != input_2_sign ? ~quotient + 1 : quotient;
                
            ALU_DIVU:
                result_o = quotient;
                
            ALU_REM:
                result_o = input_1_sign ? ~remainder + 1 : remainder;
                
            ALU_REMU:
                result_o = remainder;
                
            default:
                result_o = 32'b0;
        endcase
        
        done_o = (div_done && state == RUNNING_DIV || mul_done && state == RUNNING_MUL);
    end

    // Division
    
    always_ff @(posedge clk_i or negedge rst_n_i) begin : division_fsm
        if (!rst_n_i || flush_i) begin
            div_state <= DIV_IDLE;
            Q <= 0;
            R <= 0;
            D <= 0;
            count <= 0;
        end else begin
            div_state <= div_next_state;
            Q <= Q_next;
            R <= R_next;
            
            if (div_state == DIV_IDLE && div_start) begin
                count <= 31;
                D <= {input_2_reg, 32'b0};
                R <= {32'b0, input_1_reg};
            end else if (div_state == DIVIDE && count != 0) begin
                count <= count - 1'b1;
            end
        end
    end

    always_comb begin : division_logic
        div_next_state = div_state;
        Q_next = Q;
        R_next = R;
        
        div_done = 1'b0;
        quotient = 32'b0;
        remainder = 32'b0;
        
        case (div_state)
            DIV_IDLE: begin
                if (div_start) begin
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
                    div_next_state = DIV_FINISH;
            end

            DIV_FINISH: begin
                Q_next = Q - ~Q;
                
                if (R[63]) begin
                    R_next = R + D;
                    Q_next = Q_next - 1;
                end
                
                quotient = Q_next;
                remainder = R_next[63:32];
                
                div_done = 1'b1;
                div_next_state = DIV_IDLE;
            end
        endcase
    end
  
endmodule
