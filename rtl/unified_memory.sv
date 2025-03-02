`timescale 1ns / 1ps

//  Xilinx True Dual Port RAM Byte Write, Write First Single Clock RAM
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  The behavior of this RAM is when data is written, the new memory contents at the write
//  address are presented on the output port.

module unified_memory #(parameter NB_COL = 4,           // Specify number of columns (number of bytes)
                        parameter COL_WIDTH = 8,        // Specify column width (byte width, typically 8 or 9)
                        parameter RAM_DEPTH = 512,      // Specify RAM depth (number of entries)
                        parameter RAM_PERFORMANCE = "LOW_LATENCY",     // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
                        parameter INIT_FILE = "")       // Specify name/location of RAM initialization file if using one (leave blank if not)
                       (input  logic [$clog2(RAM_DEPTH)-1:0]  addr_a_i,     // Port A address bus, width determined from RAM_DEPTH
                        input  logic [$clog2(RAM_DEPTH)-1:0]  addr_b_i,     // Port B address bus, width determined from RAM_DEPTH
                        input  logic [(NB_COL*COL_WIDTH)-1:0] din_a_i,      // Port A RAM input data
                        input  logic [(NB_COL*COL_WIDTH)-1:0] din_b_i,      // Port B RAM input data
                        input  logic                          clk_i,        // Clock
                        input  logic [NB_COL-1:0]             we_a_i,       // Port A write enable
                        input  logic [NB_COL-1:0]             we_b_i,       // Port B write enable
                        input  logic                          en_a_i,       // Port A RAM Enable, for additional power savings, disable BRAM when not in use
                        input  logic                          en_b_i,       // Port B RAM Enable, for additional power savings, disable BRAM when not in use
                        input  logic                          rst_a_i,      // Port A output reset (does not affect memory contents)
                        input  logic                          rst_b_i,      // Port B output reset (does not affect memory contents)
                        input  logic                          regce_a_i,    // Port A output register enable
                        input  logic                          regce_b_i,    // Port B output register enable
                        
                        output logic [(NB_COL*COL_WIDTH)-1:0] dout_a_o,     // Port A RAM output data
                        output logic [(NB_COL*COL_WIDTH)-1:0] dout_b_o);    // Port B RAM output data
    
    reg [(NB_COL*COL_WIDTH)-1:0] memory [RAM_DEPTH-1:0];
    reg [(NB_COL*COL_WIDTH)-1:0] memory_data_a = {(NB_COL*COL_WIDTH){1'b0}};
    reg [(NB_COL*COL_WIDTH)-1:0] memory_data_b = {(NB_COL*COL_WIDTH){1'b0}};
    
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") begin: use_init_file
            initial
                $readmemh(INIT_FILE, memory, 0, RAM_DEPTH-1);
        end else begin: init_bram_to_zero
            integer ram_index;
            initial
                for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
                    memory[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
        end
    endgenerate
    
    generate
        genvar i;
        for (i = 0; i < NB_COL; i = i+1) begin: byte_write
            always_ff @(posedge clk_i)
                if (en_a_i)
                    if (we_a_i[i]) begin
                        memory[addr_a_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_a_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                        memory_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_a_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                    end else begin
                        memory_data_a[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= memory[addr_a_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                end

        always_ff @(posedge clk_i)
            if (en_b_i)
                if (we_b_i[i]) begin
                    memory[addr_b_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_b_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                    memory_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= din_b_i[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
                end else begin
                    memory_data_b[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= memory[addr_b_i][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
            end
        end
    endgenerate
    
    //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
    generate
        if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
        
            // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
            assign dout_a_o = memory_data_a;
            assign dout_b_o = memory_data_b;
        
        end else begin: output_register
        
            // The following is a 2 clock cycle read latency with improve clock-to-out timing
            
            reg [(NB_COL*COL_WIDTH)-1:0] douta_reg = {(NB_COL*COL_WIDTH){1'b0}};
            reg [(NB_COL*COL_WIDTH)-1:0] doutb_reg = {(NB_COL*COL_WIDTH){1'b0}};
            
            always_ff @(posedge clk_i)
                if (rst_a_i)
                    douta_reg <= {(NB_COL*COL_WIDTH){1'b0}};
                else if (regce_a_i)
                    douta_reg <= memory_data_a;
            
            always_ff @(posedge clk_i)
                if (rst_b_i)
                    doutb_reg <= {(NB_COL*COL_WIDTH){1'b0}};
                else if (regce_b_i)
                    doutb_reg <= memory_data_b;
            
            assign dout_a_o = douta_reg;
            assign dout_b_o = doutb_reg;
        
        end
    endgenerate
    
endmodule
