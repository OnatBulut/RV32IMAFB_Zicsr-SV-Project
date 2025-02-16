`timescale 1ns / 1ps

module riscv_top(input  logic       clk_sys_i, rst_n_i,
                 input  logic [3:0] sw_i,

                 output logic       ca_o, cb_o, cc_o, cd_o, ce_o, cf_o, cg_o, dp_o,
                 output logic [3:0] led_o,
                 output logic [7:0] an_o);
                 
    logic        mem_write, clock;
    logic [3:0]  seven_seg;
    logic [31:0] write_data,
                 alu_result,
                 read_data,
                 instr,
                 pc;

    riscv_core RiscV_Core(.clk_i(clk_sys_i),
                          .rst_n_i(rst_n_i),
                          .sw_i(sw_i),
                          .instr_i(instr),
                          .read_data_i(read_data),
                          .mem_write_o(mem_write),
                          .led_o(led_o),
                          .seven_seg_o(seven_seg),
                          .pc_o(pc),
                          .alu_result_o(alu_result),
                          .write_data_o(write_data));
                          
    data_memory Data_Memory(.clk_i(clk_sys_i),
                            .write_enable_i(mem_write),
                            .address_i(alu_result),
                            .write_data_i(write_data),
                            .read_data_o(read_data));
                            
    program_memory Program_Memory(.address_i(pc),
                                  .read_data_o(instr));
                                  
    seven_seg_decoder Seven_Segment_Decoder(.clk_i(clk_sys_i),
                                            .rst_n_i(rst_n_i),
                                            .number_i(seven_seg),
                                            .ca_o(ca_o),
                                            .cb_o(cb_o),
                                            .cc_o(cc_o),
                                            .cd_o(cd_o),
                                            .ce_o(ce_o),
                                            .cf_o(cf_o),
                                            .cg_o(cg_o),
                                            .dp_o(dp_o),
                                            .anode_o(an_o));

endmodule