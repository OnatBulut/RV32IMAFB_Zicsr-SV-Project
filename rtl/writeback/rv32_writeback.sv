`timescale 1ns / 1ps

module rv32_writeback (input  logic        instr_source_i,
                       input  logic [2:0]  result_source_i,
                       input  logic [31:0] instr_i,
                       input  logic [31:0] mul_div_instr_i,
                       input  logic [31:0] alu_result_i,
                       input  logic [31:0] read_data_i,
                       input  logic [31:0] pc_next_i,
                       input  logic [31:0] mul_div_result_i,
                       input  logic [31:0] fpu_result_i,
                       
                       output logic [31:0] instr_o,
                       output logic [31:0] result_o);
                       
    assign instr_o = instr_source_i ? mul_div_instr_i : instr_i;
                       
    always_comb begin : result_mux
        case (result_source_i)
            3'b000:  result_o = alu_result_i;
            3'b001:  result_o = read_data_i;
            3'b010:  result_o = pc_next_i;
            3'b011:  result_o = mul_div_result_i;
            3'b100:  result_o = fpu_result_i;
            default: result_o = 'bx;
        endcase
    end

endmodule