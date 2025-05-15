`timescale 1ns / 1ps

module rv32_top (input  logic clk_sys_i, rst_n_i,

                 input  logic uart_rx_i,
                 output logic uart_tx_o,

                 input  logic spi_miso_i,
                 output logic spi_mosi_o,
                 output logic spi_sck_o,
                 output logic spi_cs_o,

                 output logic hsync_o, vsync_o,
                 output logic [11:0] rgb444_o,
                 
                 input  logic ps2clk_i,
                 input  logic ps2data_i,
                
                 output logic read_data_o, write_data_o);
                 
    logic        clk_25MHz;
    logic [3:0]  write_enable;
    logic [31:0] instr, instr_address;
    logic [31:0] read_data, write_data, data_address;
    
    assign write_data_o = ^write_data;
    assign read_data_o = ^read_data;
    
    clk_wiz_1 clk_wiz_inst1 (
        .clk_in1(clk_sys_i),
        .resetn(rst_n_i),
        .clk_out1(clk_25MHz)
    );
                 
    rv32_core Core (.clk_i(clk_25MHz),
                    .rst_n_i(rst_n_i),
                    .instr_i(instr),
                    .read_data_i(read_data),
                    .uart_rx_i(uart_rx_i),
                    .uart_tx_o(uart_tx_o),
                    .spi_miso_i(spi_miso_i),
                    .spi_mosi_o(spi_mosi_o),
                    .spi_sck_o(spi_sck_o),
                    .spi_cs_o(spi_cs_o),
                    .hsync_o(hsync_o),
                    .vsync_o(vsync_o),
                    .rgb444_o(rgb444_o),
                    .ps2clk_i(ps2clk_i),
                    .ps2data_i(ps2data_i),
                    .memory_write_enable_o(write_enable),
                    .memory_instr_address_o(instr_address),
                    .memory_data_address_o(data_address),
                    .memory_write_data_o(write_data));
    
    //  Xilinx True Dual Port RAM Byte Write Read First Single Clock RAM
    unified_memory #(.NB_COL(4),                                        // Specify number of columns (number of bytes)
                     .COL_WIDTH(8),                                     // Specify column width (byte width, typically 8 or 9)
                     .RAM_DEPTH(65536),                                 // Specify RAM depth (number of entries)
                     .RAM_PERFORMANCE("LOW_LATENCY"),                   // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
                     .INIT_FILE("memfile.mem"))                         // Specify name/location of RAM initialization file if using one (leave blank if not)
               RAM (.addr_a_i({1'b0, instr_address[16:2]}),             // Port A address bus, width determined from RAM_DEPTH
                    .addr_b_i({data_address[28], data_address[16:2]}),  // Port B address bus, width determined from RAM_DEPTH
                    .din_a_i(32'b0),                                    // Port A RAM input data, width determined from NB_COL*COL_WIDTH
                    .din_b_i(write_data),                               // Port B RAM input data, width determined from NB_COL*COL_WIDTH
                    .clk_a_i(clk_25MHz),                                // Clock
                    .we_a_i(4'b0),                                      // Port A write enable, width determined from NB_COL
                    .we_b_i(write_enable),                              // Port B write enable, width determined from NB_COL
                    .en_a_i(1'b1),                                      // Port A RAM Enable, for additional power savings, disable port when not in use
                    .en_b_i(1'b1),                                      // Port B RAM Enable, for additional power savings, disable port when not in use
                    .rst_a_i(1'b0),                                     // Port A output reset (does not affect memory contents)
                    .rst_b_i(1'b0),                                     // Port B output reset (does not affect memory contents)
                    .regce_a_i(1'b0),                                   // Port A output register enable
                    .regce_b_i(1'b0),                                   // Port B output register enable
                    .dout_a_o(instr),                                   // Port A RAM output data, width determined from NB_COL*COL_WIDTH
                    .dout_b_o(read_data));                              // Port B RAM output data, width determined from NB_COL*COL_WIDTH
                    
endmodule
