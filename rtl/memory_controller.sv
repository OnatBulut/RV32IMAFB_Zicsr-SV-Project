`timescale 1ns / 1ps

module memory_controller(input  logic        clk_i, rst_n_i, write_enable_i,
                         input  logic [2:0]  funct3_i,
                         input  logic [3:0]  sw_i,
                         input  logic [31:0] address_i, datapath_read_i, memory_read_i,
                         
                         output logic [3:0]  led_o, seven_seg_o,
                         output logic [31:0] datapath_write_o);
    
    logic [3:0]  io_mem [2:0];
    logic [31:0] datapath_read, memory_read;
    
    // first two bits of funct3_m_o determine the size
    // third bit determines extend type (load only)                        
    // x_00 : 1 byte
    // x_01 : 2 bytes
    // 0_10 : 4 bytes
    // 0_xx : signed
    // 1_xx : unsigned
    always_comb case (funct3_i[1:0])
        2'b00: begin
            memory_read = funct3_i[2] ? {24'b0, memory_read_i[7:0]} 
                                      : {{24{memory_read_i[7]}}, memory_read_i[7:0]};
            datapath_read = {24'b0, datapath_read_i[7:0]};
        end
        2'b01: begin
            memory_read = funct3_i[2] ? {16'b0, memory_read_i[15:0]} 
                                      : {{16{memory_read_i[15]}}, memory_read_i[15:0]};
            datapath_read = {16'b0, datapath_read_i[15:0]};
        end
        2'b10: begin
            memory_read = memory_read_i;
            datapath_read = datapath_read_i;
        end 
        default: begin
            memory_read = 32'bx;
            datapath_read = 32'bx;
        end 
    endcase
    
    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (~rst_n_i) begin
            io_mem[0] <= 4'h0;
            io_mem[1] <= 4'h0;
            io_mem[2] <= 4'h0;
        end else begin
            if (write_enable_i) begin
                if (address_i == 32'h0)
                    io_mem[0] <= datapath_read[3:0];
                    
                if (address_i == 32'h4)
                    io_mem[1] <= datapath_read[3:0];
            end
        
            io_mem[2] <= sw_i;
        end
    end
    
    assign led_o = io_mem[0];
    assign seven_seg_o = io_mem[1];
    
    assign datapath_write_o = address_i == 32'h8 ? io_mem[2] : memory_read;
        
endmodule
