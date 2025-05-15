`timescale 1ns / 1ps

module rv32_fetch (input  logic        clk_i, rst_n_i,
                   input  logic        pc_source_i,
                   input  logic        stall_f_i, stall_d_i,
                   input  logic        flush_d_i,
                   input  logic [31:0] instr_i,
                   input  logic [31:0] pc_target_i,
                            
                   output logic [31:0] instr_address_o, instr_o,
                   output logic [31:0] pc_o, pc_next_o);
                   
    // Fetch Stage 1
    logic [31:0] pc_f1, pc_reg;
    logic [31:0] pc_next_f1;

    always_ff @(posedge clk_i, negedge rst_n_i) begin : program_counter
        if (!rst_n_i) begin
            pc_reg <= 32'b0;
        end else if (!stall_f_i) begin
            pc_reg <= pc_source_i ? pc_target_i : pc_next_f1; 
        end
    end
    
    assign pc_f1 = pc_reg;
    assign instr_address_o = pc_f1;
    
    assign pc_next_f1 = pc_f1 + 4;
    
    // Fetch Stage 2
    logic [31:0] pc_reg_f;
    logic [31:0] pc_next_reg_f;
    
    always_ff @(posedge clk_i, negedge rst_n_i) begin : fetch_1_to_2_pipe
        if (!rst_n_i) begin
            pc_reg_f      <= 32'b0;
            pc_next_reg_f <= 32'b0;
        end else if (!stall_f_i) begin
            pc_reg_f      <= pc_f1;
            pc_next_reg_f <= pc_next_f1;
        end
    end
    
    // Memory outputs the correct instruction here due to its one cycle delay.
    logic [31:0] input_instr;
    logic [31:0] instr_buffer;
    logic        buffer_valid;
    
    // Add instruction buffer logic
    always_ff @(posedge clk_i, negedge rst_n_i) begin : instr_buffer_logic
        if (!rst_n_i) begin
            instr_buffer <= 32'b0;
            buffer_valid <= 1'b0;
        end else if (stall_d_i && !buffer_valid) begin
            // Capture instruction during first stall cycle
            instr_buffer <= instr_i;
            buffer_valid <= 1'b1;
        end else if (!stall_d_i) begin
            // Clear buffer when stall ends
            buffer_valid <= 1'b0;
        end
    end
    
    // Use buffered instruction if valid, otherwise use direct input
    assign input_instr = buffer_valid ? instr_buffer : instr_i;
    
    // Fetch 2 to Decode
    logic [31:0] pc_reg_d;
    logic [31:0] pc_next_reg_d;
    logic [31:0] instr_reg_d;
    
    always_ff @(posedge clk_i, negedge rst_n_i) begin : fetch_2_to_decode_pipe
        if (!rst_n_i || flush_d_i) begin
            pc_reg_d      <= 32'b0;
            pc_next_reg_d <= 32'b0;
            instr_reg_d   <= 32'b0;
        end else if (!stall_d_i) begin
            pc_reg_d      <= pc_reg_f;
            pc_next_reg_d <= pc_next_reg_f;
            instr_reg_d   <= input_instr;
        end
    end
    
    assign pc_o = pc_reg_d;
    assign pc_next_o = pc_next_reg_d;
    assign instr_o = instr_reg_d;

endmodule