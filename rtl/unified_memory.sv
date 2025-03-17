`timescale 1ns / 1ps

//  Xilinx True Dual Port RAM Byte Write Read First Single Clock RAM
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  The behavior of this RAM is when data is written, the prior memory contents at the write
//  address are presented on the output port.

module unified_memory #(parameter NB_COL = 4,                           // Specify number of columns (number of bytes)
                        parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
                        parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
                        parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
                        parameter INIT_FILE = "")
                       (input [clogb2(RAM_DEPTH-1)-1:0] addr_a_i,   // Port A address bus, width determined from RAM_DEPTH
                        input [clogb2(RAM_DEPTH-1)-1:0] addr_b_i,   // Port B address bus, width determined from RAM_DEPTH
                        input [(NB_COL*COL_WIDTH)-1:0] din_a_i,     // Port A RAM input data
                        input [(NB_COL*COL_WIDTH)-1:0] din_b_i,     // Port B RAM input data
                        input clk_a_i,                              // Clock
                        input [NB_COL-1:0] we_a_i,                  // Port A write enable
                        input [NB_COL-1:0] we_b_i,                  // Port B write enable
                        input en_a_i,                               // Port A RAM Enable, for additional power savings, disable port when not in use
                        input en_b_i,                               // Port B RAM Enable, for additional power savings, disable port when not in use
                        input rst_a_i,                              // Port A output reset (does not affect memory contents)
                        input rst_b_i,                              // Port B output reset (does not affect memory contents)
                        input regce_a_i,                            // Port A output register enable
                        input regce_b_i,                            // Port B output register enable
                        
                        output [(NB_COL*COL_WIDTH)-1:0] dout_a_o,   // Port A RAM output data
                        output [(NB_COL*COL_WIDTH)-1:0] dout_b_o);  // Port B RAM output data

    (* ram_style = "block", ram_decomp = "power" *) reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
    reg [(NB_COL*COL_WIDTH)-1:0] ram_data_a = {(NB_COL*COL_WIDTH){1'b0}};
    reg [(NB_COL*COL_WIDTH)-1:0] ram_data_b = {(NB_COL*COL_WIDTH){1'b0}};
    
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") begin : use_init_file
            initial begin
                $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
            end
        end else begin : init_bram_to_zero
            integer ram_index;
            initial begin
                for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1) begin
                    BRAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
                end
            end
        end
    endgenerate
    
    always @(negedge clk_a_i) begin
        if (en_a_i) begin
            ram_data_a <= BRAM[addr_a_i];
        end
    end
    
    always @(negedge clk_a_i) begin
        if (en_b_i) begin
            ram_data_b <= BRAM[addr_b_i];
        end
    end
    
    generate
        genvar i;
            for (i = 0; i < NB_COL; i = i+1) begin : byte_write
                always @(negedge clk_a_i) begin
                    if (en_a_i) begin
                        if (we_a_i[i]) begin
                            BRAM[addr_a_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_a_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                        end
                    end
                end
                
                always @(negedge clk_a_i) begin
                    if (en_b_i) begin
                        if (we_b_i[i]) begin
                            BRAM[addr_b_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_b_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                        end
                    end
                end
            end
    endgenerate
    
    //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
    generate
        if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
        
          // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
            assign dout_a_o = ram_data_a;
            assign dout_b_o = ram_data_b;
        
        end else begin: output_register
        
          // The following is a 2 clock cycle read latency with improve clock-to-out timing
        
            reg [(NB_COL*COL_WIDTH)-1:0] dout_a_reg = {(NB_COL*COL_WIDTH){1'b0}};
            reg [(NB_COL*COL_WIDTH)-1:0] dout_b_reg = {(NB_COL*COL_WIDTH){1'b0}};
        
            always @(posedge clk_a_i) begin
                if (rst_a_i) begin
                    dout_a_reg <= {(NB_COL*COL_WIDTH){1'b0}};
                end else if (regce_a_i) begin
                    dout_a_reg <= ram_data_a;
                end
            end
        
            always @(posedge clk_a_i) begin
                if (rst_b_i) begin
                    dout_b_reg <= {(NB_COL*COL_WIDTH){1'b0}};
                end else if (regce_b_i) begin
                    dout_b_reg <= ram_data_b;
                end
            end
            
            assign dout_a_o = dout_a_reg;
            assign dout_b_o = dout_b_reg;
        
        end
    endgenerate
    
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1) begin
            depth = depth >> 1;
        end
    endfunction
    
endmodule
