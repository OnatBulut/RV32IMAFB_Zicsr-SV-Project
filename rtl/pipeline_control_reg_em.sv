`timescale 1ns / 1ps

module pipeline_control_reg_em(input  logic       clk_i, rst_n_i,
                               input  logic       mem_write_e_i, reg_write_e_i,
                               input  logic [1:0] result_src_e_i,
                                
                               output logic       mem_write_m_o, reg_write_m_o,
                               output logic [1:0] result_src_m_o);

    logic       mem_write_reg, reg_write_reg;
    logic [1:0] result_src_reg;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (~rst_n_i) begin
            mem_write_reg <= 0;
            reg_write_reg <= 0;
            result_src_reg <= 0;
        end
        else begin
            mem_write_reg <= mem_write_e_i;
            reg_write_reg <= reg_write_e_i;
            result_src_reg <= result_src_e_i;
        end
    end

    assign mem_write_m_o = mem_write_reg;
    assign reg_write_m_o = reg_write_reg;
    
    assign result_src_m_o = result_src_reg;

endmodule
