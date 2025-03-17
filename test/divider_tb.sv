`timescale 1ns / 1ps

module divider_tb;
    logic clk, rst_n, start, sign;
    logic [31:0] dividend, divisor;
    logic [31:0] quotient, remainder;
    logic done;

    non_restoring_divider uut (.clk_i(clk),
                               .rst_n_i(rst_n),
                               .start_i(start),
                               .signed_i(sign),
                               .dividend_i(dividend),
                               .divisor_i(divisor),
                               .done_o(done),
                               .quotient_o(quotient),
                               .remainder_o(remainder));

    always #1 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        sign = 0;
        #2 rst_n = 1;
        
        dividend = 5463;
        divisor  = 31;
        start = 1;
        #2 start = 0;

        wait(done);
        $display("Quotient: %d, Remainder: %d", quotient, remainder);
        #4 $finish;
    end
endmodule
