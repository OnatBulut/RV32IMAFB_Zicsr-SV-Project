`timescale 1ns / 1ps

module datapath(input  logic        clk_i, rst_n_i,
                input  logic        pc_src_i, alu_src_i, reg_write_i,
                input  logic        stall_f_i, stall_d_i, flush_d_i, flush_e_i,
                input  logic [1:0]  result_src_i, imm_src_i,
                input  logic [1:0]  forward_ae, forward_be,
                input  logic [2:0]  alu_control_i,
                input  logic [31:0] instr_i,
                input  logic [31:0] read_data_i,
                
                output logic        zero_o,
                output logic [31:0] instr_d_o, instr_e_o, instr_m_o, instr_w_o,
                output logic [31:0] pc_o, alu_result_m_o, write_data_o);
                 
    // FETCH
    
    logic [31:0] pc_target_e,
                 pc_next_f, pc_plus_4_f;
                 
    mux_2_input PC_Mux(.control_i(pc_src_i),
                       .in0_i(pc_plus_4_f),
                       .in1_i(pc_target_e),
                       .out_o(pc_next_f));
    
    register PC(.clk_i(clk_i),
                .rst_n_i(rst_n_i),
                .en_i(~stall_f_i),
                .in_i(pc_next_f),
                .out_o(pc_o));
                               
    program_counter_increment PC_Increment(.pc_i(pc_o),
                                           .pc_plus_4_o(pc_plus_4_f));
                                           
    // Pipeline Registers F - D
                                          
    logic [31:0] pc_d, pc_plus_4_d;
                           
    register Instr_Reg_FD(.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .clr_i(flush_d_i),
                          .en_i(~stall_d_i),
                          .in_i(instr_i),
                          .out_o(instr_d_o));
                            
    register PC_Reg_FD(.clk_i(clk_i),
                       .rst_n_i(rst_n_i),
                       .clr_i(flush_d_i),
                       .en_i(~stall_d_i),
                       .in_i(pc_o),
                       .out_o(pc_d));
                       
    register PC_Increment_FD(.clk_i(clk_i),
                             .rst_n_i(rst_n_i),
                             .clr_i(flush_d_i),
                             .en_i(~stall_d_i),
                             .in_i(pc_plus_4_f),
                             .out_o(pc_plus_4_d));
                             
    // DECODE
    
    logic [31:0] result_w,
                 read_data_1_d, read_data_2_d,
                 imm_ext_d;
                           
    register_file Register_File(.clk_i(clk_i),
                                .write_enable_3_i(reg_write_i),
                                .read_address_1_i(instr_d_o[19:15]),
                                .read_address_2_i(instr_d_o[24:20]),
                                .write_address_3_i(instr_w_o[11:7]),
                                .write_data_3_i(result_w),
                                .read_data_1_o(read_data_1_d),
                                .read_data_2_o(read_data_2_d));
                           
    extend Extend(.imm_src_i(imm_src_i),
                  .instr_i(instr_d_o[31:7]),
                  .imm_ext_o(imm_ext_d));
                  
    // Pipeline Registers D - E
    
    logic [31:0] read_data_1_e, read_data_2_e,
                 pc_e,
                 imm_ext_e,
                 pc_plus_4_e;
    
    register RD_1_Reg_DE(.clk_i(clk_i),
                         .rst_n_i(rst_n_i),
                         .clr_i(flush_e_i),
                         .en_i(1'b1),
                         .in_i(read_data_1_d),
                         .out_o(read_data_1_e));
                         
    register RD_2_Reg_DE(.clk_i(clk_i),
                         .rst_n_i(rst_n_i),
                         .clr_i(flush_e_i),
                         .en_i(1'b1),
                         .in_i(read_data_2_d),
                         .out_o(read_data_2_e));
    
    register PC_Reg_DE(.clk_i(clk_i),
                       .rst_n_i(rst_n_i),
                       .clr_i(flush_e_i),
                       .en_i(1'b1),
                       .in_i(pc_d),
                       .out_o(pc_e));
                  
    register Instr_Reg_DE(.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .clr_i(flush_e_i),
                          .en_i(1'b1),
                          .in_i(instr_d_o),
                          .out_o(instr_e_o));
                       
    register Imm_Ext_Reg_DE(.clk_i(clk_i),
                            .rst_n_i(rst_n_i),
                            .clr_i(flush_e_i),
                            .en_i(1'b1),
                            .in_i(imm_ext_d),
                            .out_o(imm_ext_e));
                  
    register PC_Increment_DE(.clk_i(clk_i),
                             .rst_n_i(rst_n_i),
                             .clr_i(flush_e_i),
                             .en_i(1'b1),
                             .in_i(pc_plus_4_d),
                             .out_o(pc_plus_4_e));
                  
    // EXECUTE
    
    logic [31:0] src_a_e, src_b_e, alu_result_e, write_data_e;
                  
    program_counter_target PC_Target(.pc_i(pc_e),
                                     .imm_ext_i(imm_ext_e),
                                     .pc_target_o(pc_target_e));
                                     
    mux_3_input Forward_AE_Mux(.control_i(forward_ae),
                               .in0_i(read_data_1_e),
                               .in1_i(result_w),
                               .in2_i(alu_result_m_o),
                               .out_o(src_a_e));
                               
    mux_3_input Forward_BE_Mux(.control_i(forward_be),
                               .in0_i(read_data_2_e),
                               .in1_i(result_w),
                               .in2_i(alu_result_m_o),
                               .out_o(write_data_e));
                    
    mux_2_input ALU_Mux(.control_i(alu_src_i),
                        .in0_i(write_data_e),
                        .in1_i(imm_ext_e),
                        .out_o(src_b_e));
                    
    alu ALU(.alu_control_i(alu_control_i),
            .src_a_i(src_a_e),
            .src_b_i(src_b_e),
            .zero_o(zero_o),
            .result_o(alu_result_e));
            
    // Pipeline Registers E - M
    
    logic [31:0] pc_plus_4_m;
    
    register ALU_Result_EM(.clk_i(clk_i),
                           .rst_n_i(rst_n_i),
                           .en_i(1'b1),
                           .in_i(alu_result_e),
                           .out_o(alu_result_m_o));
                             
    register Write_Data_EM(.clk_i(clk_i),
                           .rst_n_i(rst_n_i),
                           .en_i(1'b1),
                           .in_i(write_data_e),
                           .out_o(write_data_o));
                           
    register Instr_Reg_EM(.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .en_i(1'b1),
                          .in_i(instr_e_o),
                          .out_o(instr_m_o));
    
    register PC_Increment_EM(.clk_i(clk_i),
                             .rst_n_i(rst_n_i),
                             .en_i(1'b1),
                             .in_i(pc_plus_4_e),
                             .out_o(pc_plus_4_m));

    // MEMORY
    
    // Pipeline Registers M - W
    
    logic [31:0] alu_result_w,
                 read_data_w,
                 pc_plus_4_w;
    
    register ALU_Result_MW(.clk_i(clk_i),
                           .rst_n_i(rst_n_i),
                           .en_i(1'b1),
                           .in_i(alu_result_m_o),
                           .out_o(alu_result_w));
                           
    register Read_Data_MW(.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .en_i(1'b1),
                          .in_i(read_data_i),
                          .out_o(read_data_w));
                          
    register Instr_Reg_MW(.clk_i(clk_i),
                          .rst_n_i(rst_n_i),
                          .en_i(1'b1),
                          .in_i(instr_m_o),
                          .out_o(instr_w_o));
                          
    register PC_Increment_MW(.clk_i(clk_i),
                             .rst_n_i(rst_n_i),
                             .en_i(1'b1),
                             .in_i(pc_plus_4_m),
                             .out_o(pc_plus_4_w));
    
    // WRITEBACK
                          
    mux_3_input Result_Mux(.control_i(result_src_i),
                           .in0_i(alu_result_w),
                           .in1_i(read_data_w),
                           .in2_i(pc_plus_4_w),
                           .out_o(result_w));

endmodule