`timescale 1ns / 1ps

module rv32_hazard_unit (input  logic        clk_i, rst_n_i,
                         input  logic        reg_write_m_i, reg_write_m2_i, reg_write_w_i, result_src_e_i, pc_src_e_i,
                         input  logic        mul_div_done_i, mul_div_running_i,
                         input  logic [4:0]  rd_e_i, rd_m1_i, rd_m2_i, rd_w_i, rd_md_i, rs1_d_i, rs2_d_i, rs1_e_i, rs2_e_i, rs1_md_i, rs2_md_i,

                         output logic        stall_f_o, stall_d_o, stall_e_o, stall_m_o, stall_w_o, flush_d_o, flush_e_o, flush_md_o,
                         output logic [1:0]  forward_ae_o, forward_be_o);
                   
    logic lw_stall;
    logic secondary_flush_d;
                   
    always_comb begin           
        if (((rs1_e_i == rd_m1_i) && reg_write_m_i) && (rs1_e_i != 5'b0)) // Forward from Memory stage 1
            forward_ae_o = 2'b11;
        else if (((rs1_e_i == rd_m2_i) && reg_write_m2_i) && (rs1_e_i != 5'b0)) // Forward from Memory stage 2
            forward_ae_o = 2'b10;
        else if (((rs1_e_i == rd_w_i) && reg_write_w_i) && (rs1_e_i != 5'b0)) // Forward from Writeback stage
            forward_ae_o = 2'b01;
        else
            forward_ae_o = 2'b00; // No forwarding (use RF output)
            
        if (((rs2_e_i == rd_m1_i) && reg_write_m_i) && (rs2_e_i != 5'b0)) // Forward from Memory stage 1
            forward_be_o = 2'b11;
        else if (((rs2_e_i == rd_m2_i) && reg_write_m2_i) && (rs2_e_i != 5'b0)) // Forward from Memory stage 2
            forward_be_o = 2'b10;
        else if (((rs2_e_i == rd_w_i) && reg_write_w_i) && (rs2_e_i != 5'b0)) // Forward from Writeback stage
            forward_be_o = 2'b01;
        else
            forward_be_o = 2'b00; // No forwarding (use RF output)
    end
    
    assign lw_stall  = result_src_e_i == 3'b001 && ((rs1_d_i == rd_e_i) || (rs2_d_i == rd_e_i));
    assign md_stall  = mul_div_done_i || mul_div_running_i && ((rs1_d_i == rd_md_i) || (rs2_d_i == rd_md_i));
    
    assign stall_f_o = lw_stall || md_stall;
    assign stall_d_o = lw_stall || md_stall;
    assign stall_e_o = md_stall;
    assign stall_m_o = md_stall;
    assign stall_w_o = md_stall;
    
    // Decode pipe needs to be flushed twice to prevent stray instruction due to the 2 stage fetch
    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (!rst_n_i) begin
            secondary_flush_d <= 1'b0;
        end else begin
            secondary_flush_d <= pc_src_e_i;
        end
    end

    assign flush_d_o  = pc_src_e_i || secondary_flush_d;
    assign flush_e_o  = lw_stall || pc_src_e_i;
    
    assign flush_md_o = mul_div_running_i && ((rs1_md_i == rd_w_i) || (rs2_md_i == rd_w_i));

endmodule
