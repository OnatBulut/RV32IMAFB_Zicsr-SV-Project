`timescale 1ns / 1ps

module pipeline_control_reg_mw(input  logic       clk_i, rst_n_i,
                               input  logic       reg_write_m_i,
                               input  logic [1:0] result_src_m_i,
                                
                               output logic       reg_write_w_o,
                               output logic [1:0] result_src_w_o);

    logic       reg_write_reg;
    logic [1:0] result_src_reg;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (~rst_n_i) begin
            reg_write_reg <= 0;
            result_src_reg <= 0;
        end
        else begin
            reg_write_reg <= reg_write_m_i;
            result_src_reg <= result_src_m_i;
        end
    end

    assign reg_write_w_o = reg_write_reg;
    
    assign result_src_w_o = result_src_reg;

endmodule
