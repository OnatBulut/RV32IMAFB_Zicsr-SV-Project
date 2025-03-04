`ifndef DEFINES_HEADER_SVH
`define DEFINES_HEADER_SVH

`define ALU_CONTROL_SIZE 5

localparam logic [`ALU_CONTROL_SIZE-1:0] 
    ALU_ADD       = 'b00000,
    ALU_SUB       = 'b00001,
    ALU_AND       = 'b00010,
    ALU_OR        = 'b00011,
    ALU_XOR       = 'b00100,
    ALU_SLT       = 'b00101,
    ALU_SLTU      = 'b00110,
    ALU_SLL       = 'b00111,
    ALU_SRL       = 'b01000,
    ALU_SRA       = 'b01001,
    ALU_LUI       = 'b01010,
    ALU_AUIPC     = 'b01011,
    ALU_MUL       = 'b01100,
    ALU_MULH      = 'b01101,
    ALU_MULHSU    = 'b01110,
    ALU_MULHU     = 'b01111,
    ALU_DIV       = 'b10000,
    ALU_DIVU      = 'b10001,
    ALU_REM       = 'b10010,
    ALU_REMU      = 'b10011;

`endif // DEFINES_HEADER_SVH