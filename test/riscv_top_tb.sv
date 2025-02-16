`timescale 1ns / 1ps

module riscv_top_tb;

    logic clock = 1;
    logic nrst = 1;
    logic [3:0] sw = 0;
    logic [3:0] led;
            
    riscv_top RiscV_Top(.clk_sys_i(clock),
                        .rst_n_i(nrst),
                        .sw_i(sw),
                        .led_o(led));
    
    always #1 clock = ~clock;
    
    initial begin
        #2 nrst = 0;
        #2 nrst = 1;
        
        #10 sw = 4'b101;
        
        #16 nrst = 0;
        #4 nrst = 1;
        
        #8 $stop;
    end

endmodule
