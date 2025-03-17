`ifndef DEFINES_HEADER_SVH
`define DEFINES_HEADER_SVH

`define XLEN              32
`define ALU_CONTROL_WIDTH 6

localparam logic [6:0]
    OPCODE_RESET  = 7'b000_0000,
    OPCODE_LOAD   = 7'b000_0011,
    OPCODE_FENCE  = 7'b000_1111,
    OPCODE_I_TYPE = 7'b001_0011,
    OPCODE_AUIPC  = 7'b001_0111,
    OPCODE_S_TYPE = 7'b010_0011,
    OPCODE_R_TYPE = 7'b011_0011,
    OPCODE_LUI    = 7'b011_0111,
    OPCODE_B_TYPE = 7'b110_0011,
    OPCODE_JALR   = 7'b110_0111,
    OPCODE_J_TYPE = 7'b110_1111,
    OPCODE_SYSTEM = 7'b111_0011;

localparam logic [`ALU_CONTROL_WIDTH-1:0] 
    ALU_ADD       = 'b000000,
    ALU_SUB       = 'b000001,
    ALU_AND       = 'b000010,
    ALU_OR        = 'b000011,
    ALU_XOR       = 'b000100,
    ALU_SLT       = 'b000101,
    ALU_SLTU      = 'b000110,
    ALU_SLL       = 'b000111,
    ALU_SRL       = 'b001000,
    ALU_SRA       = 'b001001,
    ALU_PASS      = 'b001010,
    
    ALU_MUL       = 'b001011,
    ALU_MULH      = 'b001100, 
    ALU_MULHSU    = 'b001101, 
    ALU_MULHU     = 'b001110, 
    ALU_DIV       = 'b001111, 
    ALU_DIVU      = 'b010000, 
    ALU_REM       = 'b010001, 
    ALU_REMU      = 'b010010, 
    
    ALU_ANDN      = 'b010011, 
    ALU_ORN       = 'b010100, 
    ALU_XNOR      = 'b010101, 
    ALU_BCLR      = 'b010110, 
    ALU_BEXT      = 'b010111, 
    ALU_BINV      = 'b011000, 
    ALU_BSET      = 'b011001, 
    ALU_CLMUL     = 'b011010, 
    ALU_CLMULH    = 'b011011, 
    ALU_CLMULR    = 'b011100, 
    ALU_MAX       = 'b011101, 
    ALU_MAXU      = 'b011110, 
    ALU_MIN       = 'b011111, 
    ALU_MINU      = 'b100000, 
    ALU_ROL       = 'b100001, 
    ALU_ROR       = 'b100010, 
    ALU_SH1ADD    = 'b100011, 
    ALU_SH2ADD    = 'b100100, 
    ALU_SH3ADD    = 'b100101, 
    ALU_ZEXT_H    = 'b100110, 
    ALU_CLZ       = 'b101100, 
    ALU_CPOP      = 'b101101, 
    ALU_CTZ       = 'b101110, 
    ALU_ORC_B     = 'b101111, 
    ALU_REV8      = 'b110000, 
    ALU_SEXT_B    = 'b110001, 
    ALU_SEXT_H    = 'b110010;

`endif // DEFINES_HEADER_SVH