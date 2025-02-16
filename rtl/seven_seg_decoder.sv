`timescale 1ns / 1ps

module seven_seg_decoder(input  logic       clk_i, rst_n_i,
                         input  logic [3:0] number_i,
    
                         output logic       ca_o, cb_o, cc_o, cd_o, ce_o, cf_o, cg_o, dp_o,
                         output logic [7:0] anode_o);
    
    logic [7:0] cathode;
    
    function logic [7:0] decoder(input logic [3:0] digit);
        case (digit)
            4'h0:    decoder = 8'b0000_0011;
            4'h1:    decoder = 8'b1001_1111;
            4'h2:    decoder = 8'b0010_0101;
            4'h3:    decoder = 8'b0000_1101;
            4'h4:    decoder = 8'b1001_1001;
            4'h5:    decoder = 8'b0100_1001;
            4'h6:    decoder = 8'b0100_0001;
            4'h7:    decoder = 8'b0001_1111;
            4'h8:    decoder = 8'b0000_0001;
            4'h9:    decoder = 8'b0000_1001;
            4'ha:    decoder = 8'b0001_0001;
            4'hb:    decoder = 8'b1100_0001;
            4'hc:    decoder = 8'b0110_0011;
            4'hd:    decoder = 8'b1000_0101;
            4'he:    decoder = 8'b0110_0001;
            4'hf:    decoder = 8'b0111_0001;
            default: decoder = 8'b1111_1111;
        endcase 
    endfunction

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (~rst_n_i) begin
            anode_o <= 8'b1111_1111;
            cathode <= 8'b1111_1111;
        end else begin
            anode_o <= 8'b1111_1110;
            cathode <= decoder(number_i[3:0]);
        end
    end
         
    assign {ca_o, cb_o, cc_o, cd_o, ce_o, cf_o, cg_o, dp_o} = cathode;
         
endmodule
