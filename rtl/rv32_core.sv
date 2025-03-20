`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_core (input  logic        clk_i, rst_n_i,
                  input  logic [31:0] instr_i,
                  input  logic [31:0] read_data_i,
                 
                  output logic [3:0]  memory_write_enable_o,
                  output logic [31:0] memory_instr_address_o,
                  output logic [31:0] memory_data_address_o,
                  output logic [31:0] memory_write_data_o);
                  
    logic        stall_f, stall_d;
    logic        flush_d;
    logic        pc_source;
    logic [31:0] pc_d, pc_next_d;
    logic [31:0] pc_target;
    logic [31:0] instr_d;
    
    rv32_fetch Fetch (.clk_i(clk_i),
                      .rst_n_i(rst_n_i),
                      .pc_source_i(pc_source),
                      .stall_f_i(stall_f),
                      .stall_d_i(stall_d),
                      .flush_d_i(flush_d),
                      .instr_i(instr_i),
                      .pc_target_i(pc_target),
                      .instr_address_o(memory_instr_address_o),
                      .instr_o(instr_d),
                      .pc_o(pc_d),
                      .pc_next_o(pc_next_d));
                      
    logic        flush_e;
    logic        reg_write_e, reg_write_w;
    logic        memory_write_e;
    logic        jump;
    logic        branch;
    logic        pc_target_source;
    logic        alu_source_a, alu_source_b;
    logic [1:0]  result_source_e;
    logic [`EXCEPTION_WIDTH-1:0] exceptions_e;
    logic [`ALU_CONTROL_WIDTH-1:0] alu_control;
    logic [31:0] instr_e;
    logic [31:0] instr_w;
    logic [31:0] read_data_1, read_data_2;
    logic [31:0] pc_e, pc_next_e;
    logic [31:0] writeback_result;
    logic [31:0] immediate_extend;
                      
    rv32_decode Decode (.clk_i(clk_i),
                        .rst_n_i(rst_n_i),
                        .flush_e_i(flush_e),
                        .reg_write_enable_i(reg_write_w),
                        .reg_write_address_i(instr_w[11:7]),
                        .reg_write_data_i(writeback_result),
                        .instr_i(instr_d),
                        .pc_i(pc_d),
                        .pc_next_i(pc_next_d),
                        .reg_write_o(reg_write_e),
                        .memory_write_o(memory_write_e),
                        .jump_o(jump),
                        .branch_o(branch),
                        .pc_target_source_o(pc_target_source),
                        .alu_source_a_o(alu_source_a),
                        .alu_source_b_o(alu_source_b),
                        .result_source_o(result_source_e),
                        .exceptions_i(exceptions_e),
                        .alu_control_o(alu_control),
                        .read_data_1_o(read_data_1),
                        .read_data_2_o(read_data_2),
                        .instr_o(instr_e),
                        .pc_o(pc_e),
                        .pc_next_o(pc_next_e),
                        .imm_extend_o(immediate_extend));
    
    logic        reg_write_m;
    logic        memory_write_m;
    logic [1:0]  result_source_m;
    logic [1:0]  forward_ae, forward_be;
    logic [`EXCEPTION_WIDTH-1:0] exceptions_c;
    logic [31:0] instr_m;
    logic [31:0] pc_next_m;
    logic [31:0] alu_result_m;
    logic [31:0] write_data;
    
    rv32_execute Execute (.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .reg_write_i(reg_write_e),
                          .memory_write_i(memory_write_e),
                          .jump_i(jump),
                          .branch_i(branch),
                          .pc_target_source_i(pc_target_source),
                          .alu_source_a_i(alu_source_a),
                          .alu_source_b_i(alu_source_b),
                          .result_source_i(result_source_e),
                          .forward_a_i(forward_ae),
                          .forward_b_i(forward_be),
                          .exceptions_i(exceptions_e),
                          .alu_control_i(alu_control),
                          .instr_i(instr_e),
                          .read_data_1_i(read_data_1),
                          .read_data_2_i(read_data_2),
                          .pc_i(pc_e),
                          .pc_next_i(pc_next_e),
                          .imm_extend_i(immediate_extend),
                          .forwarded_res_w_i(writeback_result),
                          .pc_source_o(pc_source),
                          .reg_write_o(reg_write_m),
                          .memory_write_o(memory_write_m),
                          .result_source_o(result_source_m),
                          .exceptions_o(exceptions_c),
                          .instr_o(instr_m),
                          .pc_next_o(pc_next_m),
                          .alu_result_o(alu_result_m),
                          .write_data_o(write_data),
                          .pc_target_o(pc_target));
                          
    logic [31:0] mul_div_result;
                          
    rv32_mul_div Mul_Div_Unit (.clk_i(clk_i),
                               .rst_n_i(rst_n_i),
                               .alu_control_i(alu_control),
                               .read_data_1_i(read_data_1),
                               .read_data_2_i(read_data_2),
                               .running_o(),
                               .done_o(),
                               .result_o(mul_div_result));

    logic [1:0]  result_source_w;
    logic [31:0] pc_next_w;
    logic [31:0] alu_result_w;
    logic [31:0] read_data;

    rv32_memory Memory (.clk_i(clk_i),
                        .rst_n_i(rst_n_i),
                        .reg_write_i(reg_write_m),
                        .memory_write_i(memory_write_m),
                        .result_source_i(result_source_m),
                        .alu_result_i(alu_result_m),
                        .read_data_i(read_data_i),
                        .write_data_i(write_data),
                        .instr_i(instr_m),
                        .pc_next_i(pc_next_m),
                        .reg_write_o(reg_write_w),
                        .result_source_o(result_source_w),
                        .memory_write_enable_o(memory_write_enable_o),
                        .memory_data_address_o(memory_data_address_o),
                        .memory_write_data_o(memory_write_data_o),
                        .alu_result_o(alu_result_w),
                        .read_data_o(read_data),
                        .instr_o(instr_w),
                        .pc_next_o(pc_next_w));
    
    rv32_writeback Writeback (.result_source_i(result_source_w),
                              .alu_result_i(alu_result_w),
                              .read_data_i(read_data),
                              .pc_next_i(pc_next_w),
                              .mul_div_result_i(mul_div_result),
                              .instr_i(instr_w),
                              .result_o(writeback_result));
    
    // ZICSR Unit TBA
    
    rv32_hazard_unit Hazard_Unit (.clk_i(clk_i),
                                  .rst_n_i(rst_n_i),
                                  .reg_write_m_i(reg_write_m),
                                  .reg_write_w_i(reg_write_w),
                                  .result_src_e_b0_i(result_source_e[0]),
                                  .pc_src_e_i(pc_source),
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
        
endmodule
