`timescale 1ns / 1ps

module rv32_m_memory_controller (input  logic        write_enable_i,
                                 input  logic [2:0]  funct3_i,
                                 input  logic [31:0] address_i, datapath_read_i, memory_read_i,
                         
                                 output logic [3:0]  write_enable_o,
                                 output logic [31:0] datapath_write_o, memory_write_o);
                                 
    // Datapath Read  -> Data to be read from the datapath to process
    // Memory Read    -> Data to be read from the memory to process
    // Datapath Write -> Data that has been modified to be written to the datapath
    // Memory Write   -> Data that has been modified to be written to the memory

    // Datapath Read -> Logic -> Memory Write
    // Memory Read -> Logic -> Datapath Write
    
    logic [7:0]  memory_byte;
    logic [15:0] memory_halfword;
    
    // first two bits of funct3_m_o determine the size
    // third bit determines extend type (load only)                        
    // x_00 : 1 byte
    // x_01 : 2 bytes
    // 0_10 : 4 bytes
    // 0_xx : signed
    // 1_xx : unsigned
    always_comb case (funct3_i[1:0])
        2'b00: begin
            memory_byte = memory_read_i >> (address_i[1:0] * 8);
            datapath_write_o = funct3_i[2] ? {24'b0, memory_byte} 
                                      : {{24{memory_byte[7]}}, memory_byte};
            memory_write_o = datapath_read_i[7:0] << (address_i[1:0] * 8);
            write_enable_o = write_enable_i << address_i[1:0];
        end
        2'b01: begin
            memory_halfword = memory_read_i >> (address_i[1:0] * 8);
            datapath_write_o = funct3_i[2] ? {16'b0, memory_halfword} 
                                      : {{16{memory_halfword[15]}}, memory_halfword};
            memory_write_o = datapath_read_i[15:0] << (address_i[1:0] * 8);
            write_enable_o = {2{write_enable_i}} << address_i[1:0];
        end
        default: begin
            datapath_write_o = memory_read_i;
            memory_write_o = datapath_read_i;
            write_enable_o = {4{write_enable_i}};
        end 
    endcase

endmodule
