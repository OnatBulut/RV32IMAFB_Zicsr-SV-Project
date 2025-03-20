`timescale 1ns / 1ps

module rv32_writeback (input  logic        instr_source_i,
                       input  logic [1:0]  result_source_i,
                       input  logic [31:0] instr_i,
                       input  logic [31:0] muldiv_instr_i,
                       input  logic [31:0] alu_result_i,
                       input  logic [31:0] read_data_i,
                       input  logic [31:0] pc_next_i,
                       input  logic [31:0] mul_div_result_i,
                       
                       output logic [31:0] instr_o,
                       output logic [31:0] result_o);
                       
    assign instr_o = instr_source_i ? muldiv_instr_i : instr_i;
                       
    always_comb begin : result_mux
        case (result_source_i)
            2'b00: result_o = alu_result_i;
            2'b01: result_o = read_data_i;
            2'b10: result_o = pc_next_i;
            2'b11: result_o = mul_div_result_i;
        endcase
    end

endmodule