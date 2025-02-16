`timescale 1ns / 1ps

module hazard_unit(input  logic       reg_write_m_i, reg_write_w_i, result_src_e_b0_i, pc_src_e_i,
                   input  logic [4:0] rd_e_i, rd_m_i, rd_w_i, rs1_d_i, rs2_d_i, rs1_e_i, rs2_e_i,

                   output logic       stall_f_o, stall_d_o, flush_d_o, flush_e_o,
                   output logic [1:0] forward_ae_o, forward_be_o);
                   
    logic lw_stall;
                   
    always_comb begin           
        if (((rs1_e_i[4:0] == rd_m_i) & reg_write_m_i) & (rs1_e_i[4:0] != 5'b0)) // Forward from Memory stage
            forward_ae_o = 2'b10;
        else if (((rs1_e_i[4:0] == rd_w_i) & reg_write_w_i) & (rs1_e_i[4:0] != 5'b0)) // Forward from Writeback stage
            forward_ae_o = 2'b01;
        else
            forward_ae_o = 2'b00; // No forwarding (use RF output)
            
        if (((rs2_e_i[4:0] == rd_m_i) & reg_write_m_i) & (rs2_e_i[4:0] != 5'b0)) // Forward from Memory stage
            forward_be_o = 2'b10;
        else if (((rs2_e_i[4:0] == rd_w_i) & reg_write_w_i) & (rs2_e_i[4:0] != 5'b0)) // Forward from Writeback stage
            forward_be_o = 2'b01;
        else
            forward_be_o = 2'b00; // No forwarding (use RF output)
    end
    
    assign lw_stall = result_src_e_b0_i & ((rs1_d_i == rd_e_i) | (rs2_d_i == rd_e_i));
    
    assign stall_f_o = lw_stall;
    assign stall_d_o = lw_stall;
    
    assign flush_d_o = pc_src_e_i;
    assign flush_e_o = lw_stall | pc_src_e_i;

endmodule
