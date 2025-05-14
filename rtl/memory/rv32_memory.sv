`timescale 1ns / 1ps

module rv32_memory (input  logic        clk_i, rst_n_i,
                    input  logic        reg_write_i, fp_reg_write_i,
                    input  logic        memory_write_controller_i, memory_write_datapath_i,
                    input  logic [2:0]  result_source_i,
                    input  logic [31:0] alu_result_controller_i, alu_result_datapath_i,
                    input  logic [31:0] read_data_memory_i, read_data_wishbone_i,
                    input  logic [31:0] write_data_i,
                    input  logic [31:0] instr_controller_i, instr_datapath_i,
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
                    
    logic [31:0] read_data, read_data_memory;

    assign memory_data_address_o = alu_result_controller_i;

    rv32_m_memory_controller Memory_Controller (.write_enable_i(memory_write_controller_i),
                                                .address_2lsb_store_i(alu_result_controller_i[1:0]),
                                                .address_2lsb_load_i(alu_result_datapath_i[1:0]),
                                                .funct3_i(instr_controller_i[14:12]),
                                                .datapath_read_i(write_data_i),
                                                .memory_read_i(read_data_memory_i),
                                                .write_enable_o(memory_write_enable_o),
                                                .datapath_write_o(read_data_memory),
                                                .memory_write_o(memory_write_data_o));
    
    // Memory Stage
    // Memory outputs the correct data here (read_data_memory) due to its one cycle delay.

    // Determine the source to read from
    always_comb begin : read_data_mux
        case (alu_result_controller_i[31:28])
            4'b0000,
            4'b0001: read_data = read_data_memory;
            4'b0010: read_data = read_data_wishbone_i;
            default: read_data = 32'b0;
        endcase
    end
    
    // Memory to Writeback
    logic        reg_write_reg;
    logic        fp_reg_write_reg;
    logic [2:0]  result_source_reg;
    logic [31:0] alu_result_reg;
    logic [31:0] read_data_reg;
    logic [31:0] instr_reg;
    logic [31:0] pc_next_reg;
    logic [31:0] fpu_result_reg;

    always_ff @(posedge clk_i, negedge rst_n_i) begin : memory_to_writeback_pipe
        if (!rst_n_i) begin
            reg_write_reg     <= 1'b0;
            fp_reg_write_reg  <= 1'b0;
            result_source_reg <= 3'b0;
            
            alu_result_reg    <= 32'b0;
            read_data_reg     <= 32'b0;
            instr_reg         <= 32'b0;
            pc_next_reg       <= 32'b0;
            fpu_result_reg    <= 32'b0;
        end else begin
            reg_write_reg     <= reg_write_i;
            fp_reg_write_reg  <= fp_reg_write_i;
            result_source_reg <= result_source_i;
            
            alu_result_reg    <= alu_result_datapath_i;
            read_data_reg     <= read_data;
            instr_reg         <= instr_datapath_i;
            pc_next_reg       <= pc_next_i;
            fpu_result_reg    <= fpu_result_i;
        end
    end
    
    assign reg_write_o     = reg_write_reg;
    assign fp_reg_write_o  = fp_reg_write_reg;
    assign result_source_o = result_source_reg;
      
    assign alu_result_o    = alu_result_reg;
    assign read_data_o     = read_data_reg;
    assign instr_o         = instr_reg;
    assign pc_next_o       = pc_next_reg;
    assign fpu_result_o    = fpu_result_reg;

endmodule