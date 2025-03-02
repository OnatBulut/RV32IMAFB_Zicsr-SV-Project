`timescale 1ns / 1ps

module riscv_core(input  logic        clk_i, rst_n_i,
                  input  logic [3:0]  sw_i,
                  input  logic [31:0] instr_i, read_data_i,
                  
                  output logic [3:0]  mem_write_with_size_o, led_o, seven_seg_o,
                  output logic [31:0] pc_o, alu_result_o, memory_write_o);
                  
    logic        mem_write, pc_src, alu_src_a, alu_src_b, reg_write_m, reg_write_w, pc_target_src, zero;
    logic        stall_f, stall_d, flush_d, flush_e;
    logic [1:0]  forward_ae, forward_be;
    logic [1:0]  result_src_e, result_src_w;
    logic [2:0]  imm_src, funct3;
    logic [3:0]  alu_control;
    logic [31:0] instr_d, instr_e, instr_m, instr_w;
    logic [31:0] read_data_internal, write_data;
                  
    control_unit Control_Unit(.clk_i(clk_i), .rst_n_i(rst_n_i),
                              .op_i(instr_d[6:0]),
                              .funct3_d_i(instr_d[14:12]),
                              .funct7b5_i(instr_d[30]),
                              .zero_e_i(zero),
                              .flush_e_i(flush_e),
                              .pc_src_e_o(pc_src),
                              .alu_src_a_e_o(alu_src_a),
                              .alu_src_b_e_o(alu_src_b),
                              .mem_write_m_o(mem_write),
                              .reg_write_m_o(reg_write_m),
                              .reg_write_w_o(reg_write_w),
                              .pc_target_src_e_o(pc_target_src),
                              .imm_src_d_o(imm_src),
                              .result_src_w_o(result_src_w),
                              .result_src_e_o(result_src_e),
                              .alu_control_e_o(alu_control),
                              .funct3_m_o(funct3));

    datapath Datapath(.clk_i(clk_i),
                      .rst_n_i(rst_n_i),
                      .pc_src_i(pc_src),
                      .alu_src_a_i(alu_src_a),
                      .alu_src_b_i(alu_src_b),
                      .reg_write_i(reg_write_w),
                      .pc_target_src_i(pc_target_src),
                      .stall_f_i(stall_f),
                      .stall_d_i(stall_d),
                      .flush_d_i(flush_d),
                      .flush_e_i(flush_e),
                      .result_src_i(result_src_w),
                      .imm_src_i(imm_src),
                      .forward_ae(forward_ae),
                      .forward_be(forward_be),
                      .alu_control_i(alu_control),
                      .instr_i(instr_i[31:0]),
                      .read_data_i(read_data_internal),
                      .zero_o(zero),
                      .instr_d_o(instr_d),
                      .instr_e_o(instr_e),
                      .instr_m_o(instr_m),
                      .instr_w_o(instr_w),
                      .pc_o(pc_o),
                      .alu_result_m_o(alu_result_o),
                      .write_data_o(write_data));
                      
    hazard_unit Hazard_Unit(.reg_write_m_i(reg_write_m),
                            .reg_write_w_i(reg_write_w),
                            .result_src_e_b0_i(result_src_e[0]),
                            .pc_src_e_i(pc_src),
                            .rd_e_i(instr_e[11:7]),
                            .rd_m_i(instr_m[11:7]),
                            .rd_w_i(instr_w[11:7]),
                            .rs1_d_i(instr_d[19:15]),
                            .rs2_d_i(instr_d[24:20]),
                            .rs1_e_i(instr_e[19:15]),
                            .rs2_e_i(instr_e[24:20]),
                            .stall_f_o(stall_f),
                            .stall_d_o(stall_d),
                            .flush_d_o(flush_d),
                            .flush_e_o(flush_e),
                            .forward_ae_o(forward_ae),
                            .forward_be_o(forward_be));
                            
    memory_controller Memory_Controller(.clk_i(clk_i),
                                        .rst_n_i(rst_n_i),
                                        .write_enable_i(mem_write),
                                        .funct3_i(funct3),
                                        .sw_i(sw_i),
                                        .address_i(alu_result_o),
                                        .datapath_read_i(write_data),
                                        .memory_read_i(read_data_i),
                                        .led_o(led_o),
                                        .seven_seg_o(seven_seg_o),
                                        .write_enable_with_size_o(mem_write_with_size_o),
                                        .datapath_write_o(read_data_internal),
                                        .memory_write_o(memory_write_o));
                                                    
endmodule