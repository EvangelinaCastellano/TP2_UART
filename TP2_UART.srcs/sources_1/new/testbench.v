`timescale 1ns / 1ps

module tb_baudrate();

    reg i_clk;
    reg i_reset;
    wire o_tick;

    BaudRate_Generator baudrate(.i_clk(i_clk),
                                .i_reset(i_reset), 
                                .o_tick(o_tick));

    reg tx_start;
    reg [7:0] din;
    wire tx_done_tick;
    wire tx;

    Tx uart_tx(.clk(i_clk), 
               .reset(i_reset), 
               .tx_start(tx_start), 
               .s_tick(o_tick), 
               .din(din), 
               .tx_done_tick(tx_done_tick), 
               .tx(tx));

    wire rx_done_tick;
    wire [7:0] dout;

    Rx uart_rx(.clk(i_clk),
               .reset(i_reset),
               .rx(tx),
               .s_tick(o_tick),
               .rx_done_tick(rx_done_tick),
               .dout(dout));


    initial begin
        i_clk = 1'b0;
        forever #1 i_clk = ~i_clk;
    end

    initial begin
        i_reset = 1'b0;
        #1 i_reset = 1'b1;
        #3 i_reset = 1'b0;
    end

    initial begin
        #4 din = 8'b10101010;
        #5 tx_start = 1'b1;
    end

endmodule