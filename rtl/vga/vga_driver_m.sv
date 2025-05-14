`timescale 1ns / 1ps

`define VGA_WIDTH  640
`define VGA_HEIGHT 480

module vga_sync_m (
    input logic i_clk_25MHz, i_rst_n,
    output logic o_hsync, o_vsync,
    output logic o_active,
    output logic [9:0] o_hcount,
    output logic [9:0] o_vcount
);
    localparam HORZ_FPORCH = 10'd16;
    localparam HORZ_SPULSE = 10'd96;
    localparam HORZ_BPORCH = 10'd48;
    localparam HORZ_INACTIVE_LEFT  = `VGA_WIDTH + HORZ_FPORCH;
    localparam HORZ_INACTIVE_RIGHT = `VGA_WIDTH + HORZ_FPORCH + HORZ_SPULSE;
    localparam HORZ_MAX = HORZ_INACTIVE_RIGHT + HORZ_BPORCH;
        
    logic hcount_eol;
    logic [9:0] hcount;
    always_ff @(posedge i_clk_25MHz, negedge i_rst_n)
        if (!i_rst_n) begin
            hcount_eol <= 1'h0;
            hcount <= 10'h0;
        end else
            if (hcount == (HORZ_MAX - 10'h1)) begin
                hcount_eol <= 1'h1;
                hcount <= 10'h0;
            end else begin
                hcount_eol <= 1'h0;
                hcount <= hcount + 10'h1;
            end
    
    localparam VERT_FPORCH = 10'd10;
    localparam VERT_SPULSE = 10'd2;
    localparam VERT_BPORCH = 10'd33;
    localparam VERT_INACTIVE_TOP    = `VGA_HEIGHT + VERT_FPORCH;
    localparam VERT_INACTIVE_BOTTOM = `VGA_HEIGHT + VERT_FPORCH + VERT_SPULSE;
    localparam VERT_MAX = VERT_INACTIVE_BOTTOM + VERT_BPORCH;
    
    logic [9:0] vcount;
    always_ff @(posedge i_clk_25MHz, negedge i_rst_n)
        if (!i_rst_n)
            vcount <= 10'h0;
        else
            if (hcount_eol)
                if (vcount == (VERT_MAX - 10'h1))
                    vcount <= 10'h0;
                else
                    vcount <= vcount + 10'h1;
    
    assign o_hsync = ~((hcount >= HORZ_INACTIVE_LEFT) && (hcount < HORZ_INACTIVE_RIGHT));
    assign o_vsync = ~((vcount >= VERT_INACTIVE_TOP)  && (vcount < VERT_INACTIVE_BOTTOM));
    assign o_active = (hcount < `VGA_WIDTH) && (vcount < `VGA_HEIGHT);
    assign o_hcount = hcount;
    assign o_vcount = vcount;
endmodule

module font_rom_m (
    input logic [7:0] i_char,
    input logic [2:0] i_xpos,
    input logic [2:0] i_ypos,
    output logic o_is_render
);
    logic [7:0] font_rom[256][8];
    
    logic [7:0] temp_row;
    assign temp_row = font_rom[i_char][i_ypos];
    assign o_is_render = temp_row[7 - i_xpos];
    
    initial $readmemh("font_rom.mem", font_rom);
endmodule

`define COLOR_BLACK     4'h0
`define COLOR_BLUE      4'h1
`define COLOR_GREEN     4'h2
`define COLOR_CYAN      4'h3
`define COLOR_RED       4'h4
`define COLOR_PURPLE    4'h5
`define COLOR_BROWN     4'h6
`define COLOR_LTGRAY    4'h7
`define COLOR_DKGRAY    4'h8
`define COLOR_LTBLUE    4'h9
`define COLOR_LTGREEN   4'ha
`define COLOR_LTCYAN    4'hb
`define COLOR_LTRED     4'hc
`define COLOR_LTPURPLE  4'hd
`define COLOR_YELLOW    4'he
`define COLOR_WHITE	    4'hf

module color_rom_m (
    input logic [3:0] i_fg_color_sel, i_bg_color_sel,
    output logic [11:0] o_fg_color, o_bg_color
);
    logic [11:0] palette[16];
    
    assign o_fg_color = palette[i_fg_color_sel];
    assign o_bg_color = palette[i_bg_color_sel];
    
    initial begin
        palette[4'h0] = { 4'h0, 4'h0, 4'h0 };
        palette[4'h1] = { 4'ha, 4'h0, 4'h0 };
        palette[4'h2] = { 4'h0, 4'ha, 4'h0 };
        palette[4'h3] = { 4'ha, 4'ha, 4'h0 };
        palette[4'h4] = { 4'h0, 4'h0, 4'ha };
        palette[4'h5] = { 4'ha, 4'h0, 4'ha };
        palette[4'h6] = { 4'h0, 4'h5, 4'ha };
        palette[4'h7] = { 4'ha, 4'ha, 4'ha };
        palette[4'h8] = { 4'h5, 4'h5, 4'h5 };
        palette[4'h9] = { 4'hf, 4'h5, 4'h5 };
        palette[4'ha] = { 4'h5, 4'hf, 4'h5 };
        palette[4'hb] = { 4'hf, 4'hf, 4'h5 };
        palette[4'hc] = { 4'h5, 4'h5, 4'hf };
        palette[4'hd] = { 4'hf, 4'h5, 4'hf };
        palette[4'he] = { 4'h5, 4'hf, 4'hf };
        palette[4'hf] = { 4'hf, 4'hf, 4'hf };
    end
endmodule

`define VGA_COLS    (`VGA_WIDTH  / 8)
`define VGA_ROWS    (`VGA_HEIGHT / 8)

module vga_driver_m (
    input logic        i_clk, i_rst_n,
    input logic [3:0]  i_vga_mem_we,
    input logic [11:0] i_vga_mem_waddr,
    input logic [31:0] i_vga_mem_wdata,
    
    output logic o_hsync, o_vsync,
    output logic [11:0] o_rgb444
);

    logic active;
    logic [9:0] hcount, vcount;
    vga_sync_m vga_sync (
        .i_clk_25MHz(i_clk),
        .i_rst_n(i_rst_n),
        .o_hsync(o_hsync),
        .o_vsync(o_vsync),
        .o_active(active),
        .o_hcount(hcount),
        .o_vcount(vcount)
    );
    
    logic [11:0] vga_addr;
    logic [31:0] rdata;
    blk_mem_gen_0 vga_memory (
        .clka(i_clk),
        .wea(i_vga_mem_we),
        .addra(i_vga_mem_waddr),
        .dina(i_vga_mem_wdata),
        .clkb(~i_clk),
        .addrb(vga_addr),
        .doutb(rdata)
    );
    
    logic [6:0] col;
    logic [5:0] row;
    logic [2:0] xpos, ypos;
    always_comb begin
        col = hcount[9:3];
        row = vcount[8:3];
        xpos = hcount[2:0];
        ypos = vcount[2:0];
    end
    
    assign vga_addr = row * 6'd40 + { 5'h0, col[6:1] };
    
    
    logic [7:0] char;
    assign char = (~col[0]) ? rdata[7:0] : rdata[23:16];
    
    logic is_render;
    font_rom_m font_rom (
        .i_char(char),
        .i_xpos(xpos),
        .i_ypos(ypos),
        .o_is_render(is_render)
    );
    
    //TODO:
    logic [3:0] fg_color_sel;
    logic [3:0] bg_color_sel;
    always_comb begin
        if (~col[0]) begin
            fg_color_sel = rdata[11:8];
            bg_color_sel = rdata[15:12];
        end else begin
            fg_color_sel = rdata[27:24];
            bg_color_sel = rdata[31:28];
        end
    end
    
    logic [11:0] fg_color, bg_color;
    color_rom_m color_rom (
        .i_fg_color_sel(fg_color_sel),
        .o_fg_color(fg_color),
        .i_bg_color_sel(bg_color_sel),
        .o_bg_color(bg_color)
    );
    
    logic [11:0] temp_rgb444;
    assign temp_rgb444 = is_render ? fg_color : bg_color;
    
    logic [11:0] temp_rgb444_2;
    always_ff @(posedge i_clk, negedge i_rst_n)
        if (!i_rst_n)
            temp_rgb444_2 <= 12'h0;
        else
            temp_rgb444_2 <= temp_rgb444;

    assign o_rgb444 = active ? temp_rgb444_2 : 12'h0;
endmodule