`timescale 1ns / 1ps

module rv32_execute (input  logic        clk_i, rst_n_i,
                     input  logic        reg_write_i, memory_write_i, memory_data_src_i, jump_i, branch_i,
                     input  logic        pc_target_source_i, alu_source_a_i, alu_source_b_i,
                     input  logic [1:0]  forward_a_i, forward_b_i,
                     input  logic [2:0]  result_source_i,
                     input  logic [`EXCEPTION_WIDTH-1:0] exceptions_i,
                     input  logic [`ALU_CONTROL_WIDTH-1:0] alu_control_i,
                     input  logic [31:0] instr_i,
                     input  logic [31:0] read_data_1_i, read_data_2_i,
                     input  logic [31:0] pc_i, pc_next_i,
                     input  logic [31:0] imm_extend_i,
                     input  logic [31:0] forwarded_res_w_i,
                     
                     output logic        pc_source_o,
                     output logic        reg_write_o, memory_write_o,
                     output logic [2:0]  result_source_o,
                     output logic [`EXCEPTION_WIDTH-1:0] exceptions_o,

                     output logic [31:0] instr_o,
                     output logic [31:0] pc_next_o,
                     output logic [31:0] alu_result_o,
                     output logic [31:0] write_data_o,
                     output logic [31:0] pc_target_o);

    // Execute Stage Control
    logic zero;
    
    // beq    = 3'b000, zero flag 1 if true, 0^0^1 = 1
    // bne    = 3'b001, zero flag 0 if true, 0^1^0 = 1
    // blt(u) = 3'b1x0, zero flag 0 if true, 1^0^0 = 1
    // bge(u) = 3'b1x1, zero flag 1 if true, 1^1^1 = 1
    assign pc_source_o = (instr_i[14] ^ instr_i[12] ^ zero) & branch_i | jump_i;
    
    // Execute Stage Datapath
    logic [31:0] source_1, source_2, fp_source_2, write_data_mux_out;
    
    always_comb begin : forward_muxes
        case (forward_a_i)
            2'b00:   source_1 = read_data_1_i;
            2'b01:   source_1 = forwarded_res_w_i;
            2'b10:   source_1 = alu_result_o;
            default: source_1 = 32'bx;
        endcase
        
        case (forward_b_i)
            2'b00:   source_2 = read_data_2_i;
            2'b01:   source_2 = forwarded_res_w_i;
            2'b10:   source_2 = alu_result_o;
            default: source_2 = 32'bx;
        endcase
    end
    
    logic [31:0] source_b, source_a, alu_result;
    
    assign source_a = alu_source_a_i ? pc_i : source_1;
    assign source_b = alu_source_b_i ? imm_extend_i : source_2;
    assign write_data_mux_out = memory_data_src ? source_2 : fp_source_2;
    
    rv32_e_alu ALU(.alu_control_i(alu_control_i),
                   .src_a_i(source_a),
                   .src_b_i(source_b),
                   .zero_o(zero),
                   .result_o(alu_result));
            
    assign pc_target_o = (pc_target_source_i ? source_a : pc_i) + imm_extend_i;
            
    // Execute to Memory
    logic        reg_write_reg, memory_write_reg;
    logic [2:0]  result_source_reg;
    logic [`EXCEPTION_WIDTH-1:0] exceptions_reg;
    
    logic [31:0] instr_reg;
    logic [31:0] pc_next_reg;
    logic [31:0] alu_result_reg;
    logic [31:0] write_data_reg;
                    
    always_ff @(posedge clk_i, negedge rst_n_i) begin : execute_to_memory_pipe
        if (!rst_n_i) begin
            reg_write_reg     <= 1'b0;
            memory_write_reg  <= 1'b0;
            result_source_reg <= 3'b0;
            exceptions_reg    <= 'b0;
        
            instr_reg         <= 32'b0;
            pc_next_reg       <= 32'b0;
            alu_result_reg    <= 32'b0;
            write_data_reg    <= 32'b0;
        end else begin
            reg_write_reg     <= reg_write_i;
            memory_write_reg  <= memory_write_i;
            result_source_reg <= result_source_i;
            exceptions_reg    <= exceptions_i;
            
            instr_reg         <= instr_i;
            pc_next_reg       <= pc_next_i;
            alu_result_reg    <= alu_result;
            write_data_reg    <= source_2;
        end
    end
    
    assign reg_write_o     = reg_write_reg;
    assign memory_write_o  = memory_write_reg;
    assign result_source_o = result_source_reg;
    assign exceptions_o    = exceptions_reg;
    
    assign instr_o         = instr_reg;
    assign pc_next_o       = pc_next_reg;
    assign alu_result_o    = alu_result_reg;
    assign write_data_o    = write_data_reg;

endmodule