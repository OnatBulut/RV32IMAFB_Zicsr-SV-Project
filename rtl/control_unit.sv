`timescale 1ns / 1ps

module control_unit(input  logic       clk_i, rst_n_i,
                    input  logic [6:0] op_i,
                    input  logic [2:0] funct3_i,
                    input  logic       funct7b5_i,
                    input  logic       zero_e_i,
                    input  logic       flush_e_i,
                    
                    output logic       pc_src_e_o, alu_src_e_o,
                    output logic       mem_write_m_o,
                    output logic       reg_write_m_o, reg_write_w_o,
                    output logic [1:0] imm_src_d_o,
                    output logic [1:0] result_src_e_o, result_src_w_o,
                    output logic [2:0] alu_control_e_o);
    
    logic [1:0] alu_op;
    
    logic       jump_d, branch_d, mem_write_d, alu_src_d, reg_write_d;
    logic [1:0] result_src_d;
    logic [2:0] alu_control_d;
    
    logic       jump_e, branch_e, mem_write_e, reg_write_e;
    
    logic [1:0] result_src_m;
                    
    main_decoder Main_Decoder(.op_i(op_i),
                              .branch_o(branch_d),
                              .jump_o(jump_d),
                              .mem_write_o(mem_write_d),
                              .alu_src_o(alu_src_d),
                              .reg_write_o(reg_write_d),
                              .result_src_o(result_src_d),
                              .imm_src_o(imm_src_d_o),
                              .alu_op_o(alu_op));
                              
    alu_decoder ALU_Decoder(.opb5_i(op_i[5]),
                            .funct7b5_i(funct7b5_i),
                            .alu_op_i(alu_op),
                            .funct3_i(funct3_i),
                            .alu_control_o(alu_control_d));
                            
    pipeline_control_reg_de Pipeline_Control_Reg_DE(.clk_i(clk_i),
                                                    .rst_n_i(rst_n_i),
                                                    .clr_i(flush_e_i),
                                                    .jump_d_i(jump_d),
                                                    .branch_d_i(branch_d),
                                                    .mem_write_d_i(mem_write_d),
                                                    .alu_src_d_i(alu_src_d),
                                                    .reg_write_d_i(reg_write_d),
                                                    .result_src_d_i(result_src_d),
                                                    .alu_control_d_i(alu_control_d),
                                                    .jump_e_o(jump_e),
                                                    .branch_e_o(branch_e),
                                                    .mem_write_e_o(mem_write_e),
                                                    .alu_src_e_o(alu_src_e_o),
                                                    .reg_write_e_o(reg_write_e),
                                                    .result_src_e_o(result_src_e_o),
                                                    .alu_control_e_o(alu_control_e_o));
                                                    
    pipeline_control_reg_em Pipeline_Control_Reg_EM(.clk_i(clk_i),
                                                    .rst_n_i(rst_n_i),
                                                    .mem_write_e_i(mem_write_e),
                                                    .reg_write_e_i(reg_write_e),
                                                    .result_src_e_i(result_src_e_o),
                                                    .mem_write_m_o(mem_write_m_o),
                                                    .reg_write_m_o(reg_write_m_o),
                                                    .result_src_m_o(result_src_m));
                                                    
    pipeline_control_reg_mw Pipeline_Control_Reg_MW(.clk_i(clk_i),
                                                    .rst_n_i(rst_n_i),
                                                    .reg_write_m_i(reg_write_m_o),
                                                    .result_src_m_i(result_src_m),
                                                    .reg_write_w_o(reg_write_w_o),
                                                    .result_src_w_o(result_src_w_o));
        
                            
    assign pc_src_e_o = zero_e_i & branch_e | jump_e;
    
endmodule