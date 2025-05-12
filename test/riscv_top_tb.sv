`timescale 1ns / 1ps

module riscv_top_tb;

    logic clock = 1;
    logic nrst = 1;
    logic rd, wd;
            
    rv32_top RiscV_Top(.clk_sys_i(clock),
                       .rst_n_i(nrst),
                       .read_data_o(rd),
                       .write_data_o(wd));
    
    always #1 clock = ~clock;
    
    initial begin
        #2 nrst = 0;
        #4 nrst = 1;
        
        //#10 sw = 4'b101;
        
        //#16 nrst = 0;
        //#4 nrst = 1;
        
        #2008 $stop;
    end

endmodule
