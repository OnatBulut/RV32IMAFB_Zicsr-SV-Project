`timescale 1ns / 1ps

module debouncer_m (
    input logic clk_i,
    input logic in_i,
    output logic out_o
);
    logic [4:0] count;
    
    logic temp;
    initial temp = 0;
    
    always_ff @(posedge clk_i)
        if (in_i == temp) begin
            if (count == 19)
                out_o <= in_i;
            else
                count <= count + 1'h1;
        end else begin
            count <= 1'h0;
            temp <= in_i;
        end
endmodule

module ps2receiver_m (
    input logic clk_i,
    input logic ps2clk_i,
    input logic ps2data_i,
    output logic [15:0] data_o
    //output logic flag_o
);
    logic ps2clk_temp, ps2data_temp;
    logic [7:0] data_curr;
    initial data_curr = 8'h0;
    
    logic [7:0] data_prev;
    initial data_prev = 8'h0;
    
    logic [3:0] counter;
    initial counter = 4'h0;
    
    logic flag;
    initial flag = 0;
    
    debouncer_m db_clk (
        .clk_i(clk_i),
        .in_i(ps2clk_i),
        .out_o(ps2clk_temp)
    );
    
    debouncer_m db_data (
        .clk_i(clk_i),
        .in_i(ps2data_i),
        .out_o(ps2data_temp)
    );
    
    always_ff @(negedge ps2clk_temp)
        if (counter <= 4'h9) 
            counter <= counter + 4'h1;
        else if (counter == 4'ha)
            counter <= 0;
    
    always_ff @(negedge ps2clk_temp)
        case (counter)
        4'h0:;
        4'h1:   data_curr[0] <= ps2data_temp;
        4'h2:   data_curr[1] <= ps2data_temp;
        4'h3:   data_curr[2] <= ps2data_temp;
        4'h4:   data_curr[3] <= ps2data_temp;
        4'h5:   data_curr[4] <= ps2data_temp;
        4'h6:   data_curr[5] <= ps2data_temp;
        4'h7:   data_curr[6] <= ps2data_temp;
        4'h8:   data_curr[7] <= ps2data_temp;
        4'h9:   flag <= 1'b1;
        4'ha:   flag <= 1'b0;
        default: begin
            data_curr <= 8'h0;
            flag <= 1'h0;
        end
        endcase


    logic pflag;
    always_ff @(posedge clk_i)
        pflag <= flag;

    logic [15:0] data_temp;
    always_ff @(posedge clk_i)
    if (flag == 1'b1 && pflag == 1'b0) begin
        data_o <= { data_prev, data_curr };
        //flag_o <= 1'b1;
        data_prev <= data_curr;
    end
    //else flag_o <= 1'b0;



    assign data_o = data_temp;
endmodule

module keyboard_wishbone ( input  logic         clk_i, rst_n_i,
                           input  logic         wb_stb_i,
                           input  logic         wb_cyc_i,
                           input  logic         wb_adr_i,
                           input  logic         ps2clk_i,
                           input  logic         ps2data_i,
                           input  logic [3:0]   wb_sel_i,
                           
                           output logic         wb_ack_o,
                           output logic [31:0]  wb_dat_o);
                           
    logic [15:0] temp_data;
    ps2receiver_m ps2receiver (
        .clk_i(clk_i),
        .ps2clk_i(ps2clk_i),
        .ps2data_i(ps2data_i),
        .data_o(temp_data)
    );
    
    logic [31:0] char_reg;
    assign char_reg = { 16'h0, temp_data };
    
    always @(posedge clk_i) begin
      if (!rst_n_i) begin
         wb_ack_o <= 1'b0;
      end else begin
         if(wb_cyc_i) begin
            wb_ack_o <= wb_stb_i & !wb_ack_o;
            case(wb_adr_i)
               1'h0: begin
                  wb_dat_o <= char_reg;
               end
            endcase
         end
      end
   end
   
endmodule