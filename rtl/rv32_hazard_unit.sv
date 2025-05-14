`timescale 1ns / 1ps

module rv32_hazard_unit (input  logic       clk_i, rst_n_i,
                         input  logic       reg_write_m_i, reg_write_w_i, pc_src_e_i,
                         input  logic       mul_div_running_i,
                         input  logic [2:0] result_src_e_i,
                         input  logic [4:0] rd_e_i, rd_m_i, rd_w_i, rd_md_i, rs1_d_i, rs2_d_i, rs1_e_i, rs2_e_i,

                         output logic       stall_f_o, stall_d_o, flush_d_o, flush_e_o,
                         output logic [1:0] forward_ae_o, forward_be_o);
                   
    logic lw_stall;
    logic secondary_flush_d;
                   
    always_comb begin           
        if (((rs1_e_i == rd_m_i) && reg_write_m_i) && (rs1_e_i != 5'b0)) // Forward from Memory stage 1
            forward_ae_o = 2'b10;
        else if (((rs1_e_i == rd_w_i) && reg_write_w_i) && (rs1_e_i != 5'b0)) // Forward from Writeback stage
            forward_ae_o = 2'b01;
        else
            forward_ae_o = 2'b00; // No forwarding (use RF output)
            
        if (((rs2_e_i == rd_m_i) && reg_write_m_i) && (rs2_e_i != 5'b0)) // Forward from Memory stage 1
            forward_be_o = 2'b10;
        else if (((rs2_e_i == rd_w_i) && reg_write_w_i) && (rs2_e_i != 5'b0)) // Forward from Writeback stage
            forward_be_o = 2'b01;
        else
            forward_be_o = 2'b00; // No forwarding (use RF output)
    end
    
    assign lw_stall  = result_src_e_i == 3'b001 && ((rs1_d_i == rd_e_i) || (rs2_d_i == rd_e_i));
    
    assign stall_f_o = lw_stall || mul_div_running_i;
    assign stall_d_o = lw_stall || mul_div_running_i;
    
    // Decode pipe needs to be flushed twice to prevent stray instruction due to the 2 stage fetch
    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (!rst_n_i) begin
            secondary_flush_d <= 1'b0;
        end else begin
            secondary_flush_d <= pc_src_e_i;
        end
    end

    assign flush_d_o  = pc_src_e_i || secondary_flush_d;
    assign flush_e_o  = lw_stall || mul_div_running_i || pc_src_e_i;
    
endmodule
