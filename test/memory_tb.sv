`timescale 1ns / 1ps

module memory_tb;
    
    logic        clock = 1;
    logic [3:0]  mem_write_with_size;
    logic [31:0] addr_a = 32'h000, addr_b = 32'h100;
    logic [31:0] din_b, dout_a, dout_b;
    
    unified_memory #(.RAM_PERFORMANCE("LOW_LATENCY"),
                     .INIT_FILE("/home/onat/Documents/Github/RV32IMAFB_Zicsr-SV-Project/test/memtest.mem"))
            Memory  (.addr_a_i(addr_a[10:2]),
                     .addr_b_i(addr_b[10:2]),
                     .din_a_i(32'b0),
                     .din_b_i(din_b),
                     .clk_i(clock),
                     .we_a_i(4'b0),
                     .we_b_i(mem_write_with_size),
                     .en_a_i(1'b1),
                     .en_b_i(1'b1),
                     .rst_a_i(1'b0),
                     .rst_b_i(1'b0),
                     .regce_a_i(1'b1),
                     .regce_b_i(1'b1),
                     .dout_a_o(dout_a),
                     .dout_b_o(dout_b));
                     
    logic mem_write;
    logic [31:0] addr_dm = 32'h0;
    logic [31:0] din_dm, dout_dm;
                     
    data_memory Data_Memory(.clk_i(clock),
                            .write_enable_i(mem_write),
                            .address_i(addr_dm),
                            .write_data_i(din_dm),
                            .read_data_o(dout_dm));
                          
    always #1 clock = ~clock;
                          
    initial begin    
        #2;
        $display("A[%h]: %h", addr_a, dout_a);
        $display("B[%h]: %h", addr_b, dout_b);
        
        addr_a += 4;
        #2;
        $display("A[%h]: %h", addr_a, dout_a);
        $display("B[%h]: %h", addr_b, dout_b);
        
        addr_a += 4;
        #2;
        $display("A[%h]: %h", addr_a, dout_a);
        $display("B[%h]: %h", addr_b, dout_b);
        
        din_b = 32'h80;
        mem_write_with_size = 4'b0001 << addr_b[1:0];
        
        #2;
        $display("B[%h]: %h", addr_b, dout_b);
        
        addr_b += 1;
        din_b = 32'h71 << (addr_b[1:0] * 8);
        mem_write_with_size = 4'b0001 << addr_b[1:0];
        
        #2;
        $display("B[%h]: %h", addr_b, dout_b);
        
        addr_b += 1;
        din_b = 32'h5362 << (addr_b[1:0] * 8);
        mem_write_with_size = 4'b0011 << addr_b[1:0];
        
        #2;
        $display("B[%h]: %h", addr_b, dout_b);
        
        addr_b = 32'h100;
        mem_write_with_size = 4'b0;
        
        #2;
        $display("B[%h]: %h", addr_b, dout_b);
        
        
        mem_write = 1;
        din_dm = 32'h32;
        
        $display("DM[%h]: %h", addr_dm, dout_dm);
        
        #2;
        addr_dm = 32'h4;
        $display("DM[%h]: %h", addr_dm, dout_dm);
        
        #2 $stop;
    end
    
endmodule
