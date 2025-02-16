`timescale 1ns / 1ps

module register(input  logic        clk_i, rst_n_i, clr_i, en_i,
                input  logic [31:0] in_i,
               
                output logic [31:0] out_o);
                      
    logic [31:0] b_reg;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (~rst_n_i | clr_i) b_reg <= 0;
        else if (en_i) b_reg <= in_i;
    end
    
    assign out_o = b_reg;
    
endmodule
