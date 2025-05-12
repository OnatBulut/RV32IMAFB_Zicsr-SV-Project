`timescale 1ns / 1ps

module rv32_peripheral_datapath (input  logic        clk_i, rst_n_i,
                            
                                 input  logic [3:0]  mem_we_i,
                                 input  logic [31:0] mem_addr_i,
                                 input  logic [31:0] mem_data_i,
                                 output logic [31:0] mem_data_o,

                                 input  logic uart_rx_i,
                                 output logic uart_tx_o,

                                 input  logic spi_miso_i,
                                 output logic spi_mosi_o,
                                 output logic spi_sck_o,
                                 output logic spi_cs_o,

                                 output logic hsync_o, vsync_o,
                                 output logic [11:0] rgb444_o);

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

    wishbone_master Wishbone_Master (.clk_i(clk_i),
                                     .rst_n_i(rst_i),
                                     .mem_we_i(mem_we_i),
                                     .mem_addr_i(mem_addr_i),
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

    wishbone_vga_controller VGA_Controller (.clk_i(clk_i),
                                            .rst_n_i(rst_i),
                                            .wb_stb_i(wb_stb),
                                            .wb_cyc_i(vga_cyc),
                                            .wb_sel_i(wb_sel),
                                            .wb_adr_i(wb_adr[13:2]),
                                            .wb_dat_i(wb_dat),
                                            .wb_ack_o(vga_ack),
                                            .o_hsync(hsync_o),
                                            .o_vsync(vsync_o),
                                            .o_rgb444(rgb444_o));

endmodule
