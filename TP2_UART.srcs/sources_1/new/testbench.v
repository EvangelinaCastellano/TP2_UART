`timescale 1ns / 1ps

module tb_baudrate();
    reg          clk;
    reg          reset;
    reg [7 : 0]  din;
    reg          tx_start;
    reg [1 : 0]  state_reg;
    wire         tick;

    wire         data_tx_to_rx_top;
    wire         data_top_to_rx;

    wire         tx_done;
    wire         rx_done;
    wire [7 : 0] dout;

    top tb_top(
        .i_clk(clk),
        .i_reset(reset),
        .i_rx(data_tx_to_rx_top),
        .o_tx(data_top_to_rx)
        );

    BaudRate_Generator baudrate(
                        .i_clk(clk),
                        .i_reset(reset), 
                        .o_tick(tick)
                        );

    Tx uart_tx(
            .i_clk(clk), 
            .i_reset(reset), 
            .i_tx_start(tx_start), 
            .i_s_tick(tick), 
            .i_din(din), 
            .o_tx_done_tick(tx_done), 
            .o_tx(data_tx_to_rx_top)
            );

    Rx uart_rx(
            .i_clk(clk),
            .i_reset(reset),
            .i_rx(data_top_to_rx),
            .i_s_tick(tick),
            .o_rx_done_tick(rx_done),
            .o_dout(dout)
            );

    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        #2 reset = 1'b0;
    end

    initial begin
        state_reg = 2'b00;
        #5 din = 8'b00000001;//data a
        tx_start = 1'b1;
        #2  tx_start = 1'b0;

    end

    always@(*) begin
        if(tx_done)begin
            case (state_reg)
                2'b00: begin
                     din <= 8'b00000001;//data b
                    state_reg <= 2'b01;
                    #5tx_start <= 1'b1;
                    #5 tx_start <= 1'b0;
                end
                2'b01: begin
                    #1 din <= 8'b00100000;//opcode
                    state_reg <= 2'b10;
                    #5tx_start <= 1'b1;
                    #5 tx_start <= 1'b0;
                end
            endcase
        end
        if (rx_done) begin
            $finish;
            state_reg <= 2'b00;
            #5 din = 8'b00000001;//data a
            tx_start = 1'b1;
            #2 tx_start = 1'b0;
        end
    end

endmodule