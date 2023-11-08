`timescale 1ns / 1ps

module Tx
#(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)
(
    input wire i_clk, i_reset,
    input wire i_tx_start, i_s_tick,
    input wire [7:0] i_din,
    output reg o_tx_done_tick,
    output wire o_tx
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
reg tx_reg, tx_next;

always @(posedge i_clk, posedge i_reset) begin

    if(i_reset)
        begin
            state_reg <= idle;
            s_reg  <= 0;
            n_reg  <= 0;
            b_reg  <= 0;
            tx_reg <= 1'b1;
        end    
    
    else
        begin
            state_reg   <= state_next;
            s_reg       <= s_next;
            n_reg       <= n_next;
            b_reg       <= b_next;
            tx_reg      <= tx_next;
        end 
end

always @(*) begin

    state_next   = state_reg;
    o_tx_done_tick = 1'b0;
    s_next       = s_reg;
    n_next       = n_reg;
    b_next       = b_reg;
    tx_next      = tx_reg;

    case(state_reg)
        
        idle: 
            begin
                tx_next = 1'b1;         // Transmite un 1 cuando no hay datos a transmitir
                if(i_tx_start)
                begin
                    state_next = start;
                    s_next = 0;         // Reinicio contador de ticks
                    b_next = i_din;     // Se guarda en un reg lo q se va a transmitir (los 8 bits)
                end
            end

        start:
            begin
                tx_next = 1'b0;         // Inicio de la transmición (bit start)
                if(i_s_tick)
                    if(s_reg == 15)
                        begin
                            state_next = data;
                            s_next = 0; // Reinicia contador de ticks
                            n_next = 0; // Reinicia el contador de bits enviados
                        end 
                    else
                        s_next = s_reg + 1;    
            end    

        data: 
            begin
                tx_next = b_reg[0]; // Primer bit a enviar 
                if(i_s_tick)
                    if(s_reg == 15)
                        begin
                            s_next = 0;
                            b_next = b_reg >> 1;  // Desplaza los bits de salida
                            if(n_reg == (DBIT -1)) 
                                state_next = stop; // Cuando envia los 8 bits
                            else   
                                n_next = n_reg + 1; 
                        end
                    else
                        s_next = s_reg + 1;    
            end    

        stop:
            begin
                tx_next = 1'b1;                 // Bit stop
                if(i_s_tick)
                    if(s_reg == (SB_TICK-1))
                        begin
                            state_next = idle;
                            o_tx_done_tick = 1'b1; // Indica el fin de la transmicion
                        end 
                    else
                        s_next = s_reg + 1;    
            end     

    endcase
end    

// Output
assign o_tx = tx_reg;

endmodule