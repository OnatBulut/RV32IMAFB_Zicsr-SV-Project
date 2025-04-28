`timescale 1ns / 1ps

module rv32_memory (input  logic        clk_i, rst_n_i,
                    input  logic        reg_write_i, fp_reg_write_i,
                    input  logic        memory_write_i,
                    input  logic [2:0]  result_source_i,
                    input  logic [31:0] alu_result_i,
                    input  logic [31:0] read_data_i, write_data_i,
                    input  logic [31:0] instr_i,
                    input  logic [31:0] pc_next_i,
                    input  logic [31:0] fpu_result_i,
                    
                    output logic        reg_write_o, fp_reg_write_o,
                    output logic [2:0]  result_source_o,
                    
                    output logic [3:0]  memory_write_enable_o,
                    output logic [31:0] memory_data_address_o,
                    output logic [31:0] memory_write_data_o,
                    
                    output logic [31:0] alu_result_o,
                    output logic [31:0] read_data_o,
                    output logic [31:0] instr_o,
                    output logic [31:0] pc_next_o,
                    output logic [31:0] fpu_result_o);
                    
    logic [31:0] read_data_m2;

    rv32_m_memory_controller Memory_Controller (.write_enable_i(memory_write_i),
                                                .funct3_i(instr_i[14:12]),
                                                .address_i(alu_result_i),
                                                .datapath_read_i(write_data_i),
                                                .memory_read_i(read_data_i),
                                                .write_enable_o(memory_write_enable_o),
                                                .datapath_write_o(read_data_m2),
                                                .memory_write_o(memory_write_data_o));
    
    // Memory Stage 1
    assign memory_data_address_o = alu_result_i;
    
    // Memory Stage 2
    logic        reg_write_reg;
    logic        fp_reg_write_reg;
    logic [2:0]  result_source_reg;
    logic [31:0] alu_result_reg;
    logic [31:0] instr_reg;
    logic [31:0] pc_next_reg;

    always_ff @(posedge clk_i, negedge rst_n_i) begin : memory_1_to_2_pipe
        if (!rst_n_i) begin
            reg_write_reg     <= 1'b0;
            fp_reg_write_reg  <= 1'b0;
            result_source_reg <= 3'b0;
            
            alu_result_reg    <= 32'b0;
            instr_reg         <= 32'b0;
            pc_next_reg       <= 32'b0;
        end else begin
            reg_write_reg     <= reg_write_i;
            fp_reg_write_reg  <= fp_reg_write_i;
            result_source_reg <= result_source_i;
            
            alu_result_reg    <= alu_result_i;
            instr_reg         <= instr_i;
            pc_next_reg       <= pc_next_i;
        end
    end
    
    // Memory outputs the correct data here (read_data_m2) due to its one cycle delay.
    
    // Memory to Writeback
    logic        reg_write_reg_w;
    logic        fp_reg_write_reg_w;
    logic [2:0]  result_source_reg_w;
    logic [31:0] alu_result_reg_w;
    logic [31:0] read_data_reg_w;
    logic [31:0] instr_reg_w;
    logic [31:0] pc_next_reg_w;
    logic [31:0] fpu_result_reg;


    always_ff @(posedge clk_i, negedge rst_n_i) begin : memory_2_to_writeback_pipe
        if (!rst_n_i) begin
            reg_write_reg_w     <= 1'b0;
            fp_reg_write_reg_w  <= 1'b0;
            result_source_reg_w <= 3'b0;
            
            alu_result_reg_w    <= 32'b0;
            read_data_reg_w     <= 32'b0;
            instr_reg_w         <= 32'b0;
            pc_next_reg_w       <= 32'b0;
            fpu_result_reg      <= 32'b0;
        end else begin
            reg_write_reg_w     <= reg_write_reg;
            fp_reg_write_reg_w  <= fp_reg_write_reg;
            result_source_reg_w <= result_source_reg;
            
            alu_result_reg_w    <= alu_result_reg;
            read_data_reg_w     <= read_data_m2;
            instr_reg_w         <= instr_reg;
            pc_next_reg_w       <= pc_next_reg;
            fpu_result_reg      <= fpu_result_i;
        end
    end
    
    assign reg_write_o     = reg_write_reg_w;
    assign fp_reg_write_o  = fp_reg_write_reg_w;
    assign result_source_o = result_source_reg_w;
    
    assign alu_result_o    = alu_result_reg_w;
    assign read_data_o     = read_data_reg_w;
    assign instr_o         = instr_reg_w;
    assign pc_next_o       = pc_next_reg_w;
    assign fpu_result_o    = fpu_result_reg;

endmodule