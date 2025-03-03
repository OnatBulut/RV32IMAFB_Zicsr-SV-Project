`timescale 1ns / 1ps

// DEPRECATED

module data_memory (input  logic        clk_i, write_enable_i,
                    input  logic [31:0] address_i, write_data_i,
                     
                    output logic [31:0] read_data_o);

    logic [31:0] memory [63:0];

    always_ff @(posedge clk_i) begin
        if (write_enable_i) memory[address_i[31:2]] <= write_data_i;
    end
    
    assign read_data_o = memory[address_i[31:2]];
    
endmodule