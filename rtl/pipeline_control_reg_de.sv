`timescale 1ns / 1ps

module pipeline_control_reg_de(input  logic       clk_i, rst_n_i, clr_i,
                               input  logic       jump_d_i, branch_d_i, mem_write_d_i, alu_src_d_i, reg_write_d_i,
                               input  logic [1:0] result_src_d_i,
                               input  logic [2:0] alu_control_d_i,
                                
                               output logic       jump_e_o, branch_e_o, mem_write_e_o, alu_src_e_o, reg_write_e_o,
                               output logic [1:0] result_src_e_o,
                               output logic [2:0] alu_control_e_o);

    logic       jump_reg, branch_reg, mem_write_reg, alu_src_reg, reg_write_reg;
    logic [1:0] result_src_reg;
    logic [2:0] alu_control_reg;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (~rst_n_i | clr_i) begin
            jump_reg <= 0;
            branch_reg <= 0;
            mem_write_reg <= 0;
            alu_src_reg <= 0;
            reg_write_reg <= 0;
            result_src_reg <= 0;
            alu_control_reg <= 0;
        end
        else begin
            jump_reg <= jump_d_i;
            branch_reg <= branch_d_i;
            mem_write_reg <= mem_write_d_i;
            alu_src_reg <= alu_src_d_i;
            reg_write_reg <= reg_write_d_i;
            result_src_reg <= result_src_d_i;
            alu_control_reg <= alu_control_d_i;
        end
    end
    
    assign jump_e_o = jump_reg;
    assign branch_e_o = branch_reg;
    assign mem_write_e_o = mem_write_reg;
    assign alu_src_e_o = alu_src_reg;
    assign reg_write_e_o = reg_write_reg;
    
    assign result_src_e_o = result_src_reg;
    
    assign alu_control_e_o = alu_control_reg;

endmodule
