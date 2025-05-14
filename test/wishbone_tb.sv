`timescale 1ns / 1ps

module wishbone_tb;

    logic        clk = 1;
    logic        rst_n = 1;
    logic [3:0]  mem_we, mem_we_i;
    logic [31:0] mem_addr;
    logic [31:0] mem_data_i;
    logic [31:0] mem_data_o;
    
    logic        wb_we;
    logic        wb_stb;
    logic [3:0]  wb_sel;
    logic [15:0] wb_adr;
    logic [31:0] wb_dat;

    logic        uart_ack;
    logic        uart_cyc;
    logic [31:0] uart_data;

    logic        spi_ack;
    logic        spi_cyc;
    logic [31:0] spi_data;

    logic        vga_ack;
    logic        vga_cyc;

    wishbone_master Wishbone_DUT (.clk_i(clk),
                                  .rst_n_i(rst_n),
                                  .mem_we_i(mem_we_i),
                                  .mem_addr_i(mem_addr),
                                  .mem_data_i(mem_data_i),
                                  .mem_data_o(mem_data_o),
                                  .uart_cyc_o(uart_cyc),
                                  .uart_ack_i(uart_ack),
                                  .uart_data_i(uart_data),
                                  .spi_cyc_o(spi_cyc),
                                  .spi_ack_i(spi_ack),
                                  .spi_data_i(spi_data),
                                  .vga_cyc_o(vga_cyc),
                                  .vga_ack_i(vga_ack),
                                  .wb_adr_o(wb_adr),
                                  .wb_dat_o(wb_dat),
                                  .wb_we_o(wb_we),
                                  .wb_stb_o(wb_stb),
                                  .wb_sel_o(wb_sel));
                                  
    always #1 clk = !clk;
    
    // Basic wishbone slave
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            uart_ack <= 1'b0;
        end else begin
            if(uart_cyc) begin
                uart_ack <= wb_stb & !uart_ack;
            end
        end
    end
    
    // Address block mux
    always_comb begin : write_enable_demux
        case (mem_addr[31:28])
            4'b0010: mem_we_i = mem_we;
            default: mem_we_i = 4'b0000;
        endcase
    end
    
    initial begin
        #2 rst_n = 0;
        #4 rst_n = 1;
        
        mem_we     = 4'b1111;
        mem_addr   = 32'h20000000;
        mem_data_i = 32'h4f3f2f1f;
        
        #2;
        
        mem_we     = 4'b0110;
        mem_addr   = 32'h10000501;
        mem_data_i = 32'h0059ea00;
        
        #2;
        
        mem_we     = 4'b0000;
        mem_addr   = 32'h00000000;
        mem_data_i = 32'h00000000;
        
        #4 $stop;
    end
    
endmodule
