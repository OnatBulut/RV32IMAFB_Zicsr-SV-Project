`timescale 1ns / 1ps

module memory_controller(input  logic        clk_i, rst_n_i, write_enable_i,
                         input  logic [3:0]  sw_i,
                         input  logic [31:0] address_i, datapath_read_i, memory_read_i,
                         
                         output logic [3:0]  led_o, seven_seg_o,
                         output logic [31:0] datapath_write_o);
    
    logic [3:0] io_mem [2:0];
    
    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (~rst_n_i) begin
            io_mem[0] <= 4'h0;
            io_mem[1] <= 4'h0;
            io_mem[2] <= 4'h0;
        end else begin
            if (write_enable_i) begin
                if (address_i == 32'h0)
                    io_mem[0] <= datapath_read_i[3:0];
                    
                if (address_i == 32'h4)
                    io_mem[1] <= datapath_read_i[3:0];
            end
        
            io_mem[2] <= sw_i;
        end
    end
    
    assign led_o = io_mem[0];
    assign seven_seg_o = io_mem[1];
    
    assign datapath_write_o = address_i == 32'h8 ? io_mem[2] : memory_read_i;
        
endmodule
