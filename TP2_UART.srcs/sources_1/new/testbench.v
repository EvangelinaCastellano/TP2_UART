`timescale 1ns / 1ps

module tb_baudrate();

    reg i_clk;
    reg i_reset;
    reg [0 : 3] control_bit;
    wire tick;
    wire tx_start_alu_intf_to_tx;
    wire [7 : 0] tx_alu_intf_to_din_tx;
    wire rx_done_rx_to_read_done_alu_intf;
    wire [7 : 0] dout_rx_to_rx_data_alu_intf;
    wire [7 : 0] data_a_alu_intf_to_alu;
    wire [7 : 0] data_b_alu_intf_to_alu;
    wire [5 : 0] opcode_alu_intf_to_alu;
    wire [7 : 0] data_alu_to_alu_result_alu_intf;
     

    wire o_tx_done_tick; //Flag para ver en la simulacion
    wire o_tx;

    BaudRate_Generator baudrate(.i_clk(i_clk),
                                .i_reset(i_reset), 
                                .o_tick(tick));

    reg i_rx; //Valor de entrada

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
        #4 i_rx = 1'b1;//data_a
        control_bit = 4'b0000;
        #100000000 i_rx = 1'b0;
        control_bit = 4'b0001;
        #100000000 i_rx = 1'b1;
        control_bit = 4'b0010;
        #100000000 i_rx = 1'b0;
        control_bit = 4'b0011;
        #100000000 i_rx = 1'b1;
        control_bit = 4'b0100;
        #100000000 i_rx = 1'b0;
        control_bit = 4'b0101;
        #100000000 i_rx = 1'b1;
        control_bit = 4'b0110;
        #100000000 i_rx = 1'b0;
        control_bit = 4'b0111;
        // #100 i_rx = 8'b00000001;//data_b
        // #100 i_rx = 8'b00100000;//opcode
        
    end

endmodule