`timescale 1ns / 1ps

module riscv_top(input  logic       clk_sys_i, rst_n_i,
                 input  logic [3:0] sw_i,

                 output logic       ca_o, cb_o, cc_o, cd_o, ce_o, cf_o, cg_o, dp_o,
                 output logic [3:0] led_o,
                 output logic [7:0] an_o);
                 
    logic        clock;
    logic [3:0]  mem_write, seven_seg;
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
                          .mem_write_with_size_o(mem_write),
                          .led_o(led_o),
                          .seven_seg_o(seven_seg),
                          .pc_o(pc),
                          .alu_result_o(alu_result),
                          .memory_write_o(write_data));
                          
    unified_memory #(.INIT_FILE("/home/onat/Documents/Github/RV32IMAFB_Zicsr-SV-Project/rtl/memfile.mem"))
            Memory  (.addr_a_i(pc[14:2]),
                     .addr_b_i(alu_result[14:2]),
                     .din_a_i(32'b0),
                     .din_b_i(write_data),
                     .clk_i(clk_sys_i),
                     .we_a_i(4'b0),
                     .we_b_i(mem_write),
                     .en_a_i(1'b1),
                     .en_b_i(1'b1),
                     .rst_a_i(1'b0),
                     .rst_b_i(1'b0),
                     .regce_a_i(1'b1),
                     .regce_b_i(1'b1),
                     .dout_a_o(instr),
                     .dout_b_o(read_data));
                                  
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