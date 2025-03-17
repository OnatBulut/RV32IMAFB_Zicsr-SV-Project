`timescale 1ns / 1ps

module rv32_writeback (input  logic [1:0]  result_source_i,
                       input  logic [31:0] alu_result_i,
                       input  logic [31:0] read_data_i,
                       input  logic [31:0] pc_next_i,
                       
                       output logic [31:0] result_o);
                       
    always_comb begin : result_mux
        case (result_source_i)
            2'b00:   result_o = alu_result_i;
            2'b01:   result_o = read_data_i;
            2'b10:   result_o = pc_next_i;
            default: result_o = 32'bx;
        endcase
    end

endmodule