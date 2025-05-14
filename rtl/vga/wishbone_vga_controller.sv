module wishbone_vga_controller (input  logic        clk_i, rst_n_i,
                                input  logic        wb_stb_i,
                                input  logic        wb_cyc_i,
                                input  logic        wb_we_i,
                                input  logic [3:0]  wb_sel_i,
                                input  logic [11:0] wb_adr_i,
                                input  logic [31:0] wb_dat_i,
                                
                                output logic        wb_ack_o,
                                output logic        o_hsync, o_vsync,
                                output logic [11:0] o_rgb444);

        logic [3:0] vga_mem_we;

        vga_driver_m vga_driver (
        .i_clk(clk_i),
        .i_rst_n(rst_n_i),
        .i_vga_mem_we(vga_mem_we),
        .i_vga_mem_waddr(wb_adr_i),
        .i_vga_mem_wdata(wb_dat_i),
        .o_hsync(o_hsync),
        .o_vsync(o_vsync),
        .o_rgb444(o_rgb444)
    );

    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (!rst_n_i) begin
            wb_ack_o   <= 1'b0;
            vga_mem_we <= 4'b0000;
        end else begin
            if (wb_cyc_i) begin
                wb_ack_o <= wb_stb_i & !wb_ack_o;
                if (wb_stb_i & wb_we_i & !wb_ack_o) begin
                    vga_mem_we <= wb_sel_i;
                end
            end
        end
    end

endmodule