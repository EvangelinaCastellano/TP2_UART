`timescale 1ns / 1ps

module BaudRate_Generator
#(
    parameter NB_BaudRate    = 16,
    parameter BaudRate       = 9600 
)
(
    input   i_clk,
    input   i_reset,
    
    output  o_tick
);

reg [NB_BaudRate -1 : 0] BaudRate_reg;

always @(posedge i_clk) begin
    if(i_reset || o_tick)
        BaudRate_reg <= {NB_BaudRate{1'b0}};
    else     
        BaudRate_reg <= BaudRate_reg + 1'b1;
end

assign o_tick = (BaudRate_reg == BaudRate - 1'b1);

endmodule
