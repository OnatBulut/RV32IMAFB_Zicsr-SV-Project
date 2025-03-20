`timescale 1ns / 1ps


module rv32_d_fp_register_file (input  logic        clk_i, write_enable_4_i,
                                input  logic [4:0]  read_address_1_i, read_address_2_i, read_address_3_i, write_address_4_i,
                                input  logic [31:0] write_data_4_i,
               
                                output logic [31:0] read_data_1_o, read_data_2_o, read_data_3_o);

    logic [31:0] rf [31:0];

    always_ff @(negedge clk_i)
        if (write_enable_4_i) rf[write_address_4_i] <= write_data_4_i;

    assign read_data_1_o = rf[read_address_1_i];  
    assign read_data_2_o = rf[read_address_2_i];
    assign read_data_3_o = rf[read_address_3_i];
    
endmodule