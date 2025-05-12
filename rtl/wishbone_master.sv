`timescale 1ns / 1ps

module wishbone_master (input  logic        clk_i, rst_n_i,

                        input  logic [3:0]  mem_we_i,
                        input  logic [31:0] mem_addr_i,
                        input  logic [31:0] mem_data_i,
                        output logic [31:0] mem_data_o,

                        input  logic        uart_ack_i,
                        input  logic [31:0] uart_data_i,
                        output logic        uart_cyc_o,

                        input  logic        spi_ack_i,
                        input  logic [31:0] spi_data_i,
                        output logic        spi_cyc_o,

                        input  logic        vga_ack_i,
                        output logic        vga_cyc_o,

                        output logic        wb_we_o,
                        output logic        wb_stb_o,
                        output logic [3:0]  wb_sel_o,
                        output logic [15:0] wb_adr_o,
                        output logic [31:0] wb_dat_o);

    logic cyc, ack;

    always_comb case(mem_addr_i[17:16])
        2'b00:   begin ack = uart_ack_i; mem_data_o = uart_data_i; end
        2'b01:   begin ack = spi_ack_i;  mem_data_o = spi_data_i;  end
        2'b10:   begin ack = vga_ack_i;  mem_data_o = 32'b0;       end
        default: begin ack = 1'b0;       mem_data_o = 32'b0;       end
    endcase

    assign wb_adr_o = mem_addr_i[15:0];
    assign wb_dat_o = mem_data_i;
    assign wb_we_o  = |mem_we_i;
    assign wb_sel_o = mem_we_i;

    assign uart_cyc_o = (mem_addr_i[17:16] == 2'b00) ? cyc : 1'b0;
    assign spi_cyc_o  = (mem_addr_i[17:16] == 2'b01) ? cyc : 1'b0;
    assign vga_cyc_o  = (mem_addr_i[17:16] == 2'b10) ? cyc : 1'b0;

    typedef enum logic { IDLE, BUS } bus_state_t;
    bus_state_t state, next_state;

    always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case(state)
            IDLE: begin
                if (mem_we_i) begin
                    next_state = BUS;
                end else begin
                    next_state = IDLE;
                end

                wb_stb_o = 1'b0;
                cyc      = 1'b0;
            end
            BUS: begin
                if (ack) begin
                    next_state = IDLE;
                end else begin
                    next_state = BUS;
                end

                wb_stb_o = 1'b1;
                cyc      = 1'b1;
            end
            default:  next_state = IDLE;
        endcase
    end
endmodule
