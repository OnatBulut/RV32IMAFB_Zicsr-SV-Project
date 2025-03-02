`timescale 1ns / 1ps

// DEPRECATED

module program_memory(input  logic [31:0] address_i,

                      output logic [31:0] read_data_o);

    logic  [31:0] rom [63:0];

    initial begin
        $readmemh("./memfile.mem", rom);
    end

    assign read_data_o = rom[address_i[31:2]];
    
endmodule