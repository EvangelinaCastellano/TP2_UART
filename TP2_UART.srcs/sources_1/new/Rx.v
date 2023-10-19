`timescale 1ns / 1ps
module Rx
#(
    parameter DBIT      = 8, // Cantidad de bits del dato
    parameter SB_TICK   = 16 // Cantidad de ticks
)
(
    input wire clk,
    input wire reset,
    input wire rx,
    input wire s_tick,

    output reg rx_done_tick,
    output wire [7:0] dout
);

// Estados
localparam [1:0] idle  = 2'b00;
localparam [1:0] start = 2'b01;
localparam [1:0] data  = 2'b10;
localparam [1:0] stop  = 2'b11;

// Señales
reg [1:0] state_reg, state_next;
reg [3:0] s_reg, s_next;   // Numero de ticks en el estado actual
reg [2:0] n_reg, n_next;   // Cantidad de bits recibidos
reg [7:0] b_reg, b_next;   // Valor recibido

always @(posedge clk, posedge reset) begin

    if(reset)
        begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end    
    
    else
        begin
            state_reg   <= state_next;
            s_reg       <= s_next;
            n_reg       <= n_next;
            b_reg       <= b_next;
        end 
end

always @(*) begin

    state_next   = state_reg;
    rx_done_tick = 1'b0;
    s_next       = s_reg;
    n_next       = n_reg;
    b_next       = b_reg;

    case(state_reg)
        idle:
            if (~rx)
                begin
                    state_next = start;
                    s_next     = 0;
                end

        start:
            if(s_tick)
                if(s_reg == 7)
                    begin
                        state_next = data;
                        s_next     = 0;
                        n_next     = 0;
                    end        
                else
                    s_next = s_reg + 1;

        data:
            if(s_tick)
                if (s_reg == 15)    
                    begin
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]};
                        if (n_reg == (DBIT - 1))
                            state_next = stop;
                        else
                            n_next = n_reg + 1;    
                    end   
                else
                    s_next = s_reg + 1;
        
        stop:
            if(s_tick)
                if( s_reg == (SB_TICK -1))
                    begin
                        state_next   = idle;
                        rx_done_tick = 1'b1;
                    end
                else
                    s_next = s_reg + 1;
    endcase                    
end

//Output
assign dout = b_reg;

endmodule