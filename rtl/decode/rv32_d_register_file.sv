`timescale 1ns / 1ps


module rv32_d_register_file (input  logic        clk_i, write_enable_3_i,
                             input  logic [4:0]  read_address_1_i, read_address_2_i, write_address_3_i,
                             input  logic [31:0] write_data_3_i,
               
                             output logic [31:0] read_data_1_o, read_data_2_o);

    logic [31:0] rf [31:1];

    always_ff @(negedge clk_i) begin
        if (write_enable_3_i) rf[write_address_3_i] <= write_data_3_i;
    end 

    assign read_data_1_o = (read_address_1_i == 5'b0) ? 32'b0 : rf[read_address_1_i];  
    assign read_data_2_o = (read_address_2_i == 5'b0) ? 32'b0 : rf[read_address_2_i];
    
endmodule