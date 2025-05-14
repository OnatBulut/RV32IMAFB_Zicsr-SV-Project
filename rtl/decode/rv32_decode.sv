`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_decode (input  logic        clk_i, rst_n_i,
                    input  logic        flush_e_i,
                    input  logic        reg_write_enable_i,
                    input  logic        fp_reg_write_enable_i,
                    input  logic [4:0]  reg_write_address_i,
                    input  logic [31:0] reg_write_data_i,
                    input  logic [31:0] instr_i,
                    input  logic [31:0] pc_i, pc_next_i,
                    
                    output logic        reg_write_o, fp_reg_write_o, memory_write_o, memory_data_src_o, jump_o, branch_o,
                    output logic        pc_target_source_o, alu_source_a_o, alu_source_b_o,
                    output logic [2:0]  result_source_o,
                    output logic [`EXCEPTION_WIDTH-1:0] exceptions_o,
                    output logic [`ALU_CONTROL_WIDTH-1:0] alu_control_o,
                    
                    output logic [31:0] read_data_1_o, read_data_2_o,
                    output logic [31:0] fp_read_data_1_o, fp_read_data_2_o, fp_read_data_3_o,
                    output logic [31:0] instr_o,
                    output logic [31:0] pc_o, pc_next_o,
                    output logic [31:0] imm_extend_o);
                    
    // Decode Stage Control
    logic        valid_instr, valid_op, system_noncsr;
    logic        reg_write, fp_reg_write, memory_write, memory_data_src, jump, branch, pc_target_source;
    logic        alu_source_a, alu_source_b;
    logic [2:0]  result_source;
    logic [2:0]  imm_source;
    logic [3:0]  alu_op;
    logic [`EXCEPTION_WIDTH-1:0] exceptions;
    logic [`ALU_CONTROL_WIDTH-1:0] alu_control;
    
    rv32_d_main_decoder Main_Decoder (.opcode_i(instr_i[6:0]),
                                      .valid_instr_o(valid_instr),
                                      .branch_o(branch),
                                      .jump_o(jump),
                                      .mem_write_o(memory_write),
                                      .mem_data_src_o(memory_data_src),
                                      .alu_src_a_o(alu_source_a),
                                      .alu_src_b_o(alu_source_b),
                                      .reg_write_o(reg_write),
                                      .fp_reg_write_o(fp_reg_write),
                                      .pc_target_src_o(pc_target_source),
                                      .result_src_o(result_source),
                                      .alu_op_o(alu_op),
                                      .imm_src_o(imm_source));
                                     
    rv32_d_alu_decoder ALU_Decoder (.alu_op_i(alu_op),
                                    .valid_op_o(valid_op),
                                    .instr_i(instr_i),
                                    .alu_control_o(alu_control));
                                    
    assign system_noncsr = instr_i[6:0] == OPCODE_SYSTEM && instr_i[14:12] == 0;
    assign exceptions = {
        (system_noncsr && instr_i[21:20] == 2'b10), // EXCEPTION_MRET    at bit 3
        (system_noncsr && instr_i[21:20] == 2'b01), // EXCEPTION_EBREAK  at bit 2
        (system_noncsr && instr_i[21:20] == 2'b00), // EXCEPTION_ECALL   at bit 1
        (!valid_instr || !valid_op)                 // EXCEPTION_ILLEGAL at bit 0
    };
                                    
    // Decode Stage Datapath
    logic [31:0] read_data_1, read_data_2;
    
    rv32_d_register_file Register_File (.clk_i(clk_i),
                                        .write_enable_3_i(reg_write_enable_i),
                                        .read_address_1_i(instr_i[19:15]),
                                        .read_address_2_i(instr_i[24:20]),
                                        .write_address_3_i(reg_write_address_i),
                                        .write_data_3_i(reg_write_data_i),
                                        .read_data_1_o(read_data_1),
                                        .read_data_2_o(read_data_2));

    logic [31:0] fp_read_data_1, fp_read_data_2, fp_read_data_3;

    rv32_d_fp_register_file FP_Register_File (.clk_i(clk_i),
                                              .write_enable_4_i(fp_reg_write_enable_i),
                                              .read_address_1_i(instr_i[19:15]),
                                              .read_address_2_i(instr_i[24:20]),
                                              .read_address_3_i(instr_i[31:27]),
                                              .write_address_4_i(reg_write_address_i),
                                              .write_data_4_i(reg_write_data_i),
                                              .read_data_1_o(fp_read_data_1),
                                              .read_data_2_o(fp_read_data_2),
                                              .read_data_3_o(fp_read_data_3));                                

    logic [31:0] imm_extend;
                                       
    rv32_d_extend Extend (.imm_src_i(imm_source),
                          .instr_i(instr_i[31:7]),
                          .imm_ext_o(imm_extend));
                  
    // Decode to Execute
    logic        reg_write_reg, fp_reg_write_reg, memory_write_reg, memory_data_src_reg, jump_reg, branch_reg, pc_target_source_reg;
    logic        alu_source_a_reg, alu_source_b_reg;
    logic [2:0]  result_source_reg;
    logic [`EXCEPTION_WIDTH-1:0] exceptions_reg;
    logic [`ALU_CONTROL_WIDTH-1:0] alu_control_reg;
    
    logic [31:0] instr_reg;
    logic [31:0] read_data_1_reg, read_data_2_reg;
    logic [31:0] fp_read_data_1_reg, fp_read_data_2_reg, fp_read_data_3_reg;
    logic [31:0] pc_reg, pc_next_reg;
    logic [31:0] imm_extend_reg;
                    
    always_ff @(posedge clk_i, negedge rst_n_i) begin : decode_to_execute_pipe
        if (!rst_n_i || flush_e_i) begin
            reg_write_reg        <= 1'b0;
            fp_reg_write_reg     <= 1'b0;
            memory_write_reg     <= 1'b0;
            memory_data_src_reg  <= 1'b0;
            jump_reg             <= 1'b0;
            branch_reg           <= 1'b0;
            pc_target_source_reg <= 1'b0;
            alu_source_a_reg     <= 1'b0;
            alu_source_b_reg     <= 1'b0;
            result_source_reg    <= 3'b0;
            exceptions_reg       <= 'b0;
            alu_control_reg      <= 'b0;
        
            instr_reg            <= 32'b0;
            read_data_1_reg      <= 32'b0;
            read_data_2_reg      <= 32'b0;
            fp_read_data_1_reg   <= 32'b0;
            fp_read_data_2_reg   <= 32'b0;
            fp_read_data_3_reg   <= 32'b0;
            pc_reg               <= 32'b0;
            pc_next_reg          <= 32'b0;
            imm_extend_reg       <= 32'b0;
        end else begin
            reg_write_reg        <= reg_write;
            fp_reg_write_reg     <= fp_reg_write;
            memory_write_reg     <= memory_write;
            memory_data_src_reg  <= memory_data_src;
            jump_reg             <= jump;
            branch_reg           <= branch;
            pc_target_source_reg <= pc_target_source;
            alu_source_a_reg     <= alu_source_a;
            alu_source_b_reg     <= alu_source_b;
            result_source_reg    <= result_source;
            exceptions_reg       <= exceptions;
            alu_control_reg      <= alu_control;
            
            instr_reg            <= instr_i;
            read_data_1_reg      <= read_data_1;
            read_data_2_reg      <= read_data_2;
            fp_read_data_1_reg   <= fp_read_data_1;
            fp_read_data_2_reg   <= fp_read_data_2;
            fp_read_data_3_reg   <= fp_read_data_3;
            pc_reg               <= pc_i;
            pc_next_reg          <= pc_next_i;
            imm_extend_reg       <= imm_extend;
        end
    end
    
    assign reg_write_o        = reg_write_reg;
    assign fp_reg_write_o     = fp_reg_write_reg;
    assign memory_write_o     = memory_write_reg;
    assign memory_data_src_o  = memory_data_src_reg;
    assign jump_o             = jump_reg;
    assign branch_o           = branch_reg;
    assign pc_target_source_o = pc_target_source_reg;
    assign alu_source_a_o     = alu_source_a_reg;
    assign alu_source_b_o     = alu_source_b_reg;
    assign result_source_o    = result_source_reg;
    assign exceptions_o       = exceptions_reg;
    assign alu_control_o      = alu_control_reg;
    
    assign instr_o            = instr_reg;
    assign read_data_1_o      = read_data_1_reg;
    assign read_data_2_o      = read_data_2_reg;
    assign fp_read_data_1_o   = fp_read_data_1_reg;
    assign fp_read_data_2_o   = fp_read_data_2_reg;
    assign fp_read_data_3_o   = fp_read_data_3_reg;
    assign pc_o               = pc_reg;
    assign pc_next_o          = pc_next_reg;
    assign imm_extend_o       = imm_extend_reg;

endmodule