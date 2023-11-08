`timescale 1ns / 1ps

module top(
    input i_clk,
    input i_reset,
    input i_rx,
    
    output  [8 - 1 : 0]        o_data, 
    output o_tx
);

wire tick;
wire tx_start_alu_intf_to_tx;
wire [7 : 0] tx_alu_intf_to_din_tx;
wire rx_done_rx_to_read_done_alu_intf;
wire [7 : 0] dout_rx_to_rx_data_alu_intf;
wire [7 : 0] data_a_alu_intf_to_alu;
wire [7 : 0] data_b_alu_intf_to_alu;
wire [5 : 0] opcode_alu_intf_to_alu;
wire [7 : 0] data_alu_to_alu_result_alu_intf;

reg [8 -1 : 0] data_out;               // Contains the result of the operation

assign o_data = data_out;  

BaudRate_Generator baudrate(
                        .i_clk(i_clk),
                        .i_reset(i_reset), 
                        .o_tick(tick)
                        );

Tx uart_tx(.i_clk(i_clk), 
               .i_reset(i_reset), 
               .i_tx_start(tx_start_alu_intf_to_tx), 
               .i_s_tick(tick), 
               .i_din(tx_alu_intf_to_din_tx), 
               .o_tx_done_tick(o_tx_done_tick), 
               .o_tx(o_tx));


Rx uart_rx(.i_clk(i_clk),
           .i_reset(i_reset),
           .i_rx(i_rx),
           .i_s_tick(tick),
           .o_rx_done_tick(rx_done_rx_to_read_done_alu_intf),
           .o_dout(dout_rx_to_rx_data_alu_intf));


ALU alu(.i_data_a(data_a_alu_intf_to_alu),
        .i_data_b(data_b_alu_intf_to_alu),
        .i_operation(opcode_alu_intf_to_alu),
        .o_data(data_alu_to_alu_result_alu_intf));

ALU_interface alu_interface(.i_clk(i_clk),
                            .i_reset(i_reset),
                            .i_read_done(rx_done_rx_to_read_done_alu_intf),
                            .i_rx_data(dout_rx_to_rx_data_alu_intf),
                            .i_alu_result(data_alu_to_alu_result_alu_intf),
                            .o_tx_start(tx_start_alu_intf_to_tx),
                            .o_tx(tx_alu_intf_to_din_tx),
                            .o_data_a(data_a_alu_intf_to_alu),
                            .o_data_b(data_b_alu_intf_to_alu),
                            .o_opcode(opcode_alu_intf_to_alu));

always @(posedge i_clk) begin
    if (i_reset)              
        data_out <= {8 {1'b0}}; // Clean reg
    else if(rx_done_rx_to_read_done_alu_intf)
        data_out <= dout_rx_to_rx_data_alu_intf; //Saves the data B loaded on the switches
    else if(tx_start_alu_intf_to_tx)
        data_out <= data_alu_to_alu_result_alu_intf;
end


endmodule
