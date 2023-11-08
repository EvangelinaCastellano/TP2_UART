`timescale 1ns / 1ps

module ALU_interface
#(
    parameter DATA_SIZE   = 8,
    parameter OPCODE_SIZE = 6
)
(
    input i_clk, i_reset,
    input i_read_done,                      // Avisa cuando Rx termino de leer un dato
    input [DATA_SIZE - 1 : 0] i_rx_data,    // Dato recibido por Rx
    input [DATA_SIZE - 1 : 0] i_alu_result, // Resultado de la ALU

    output o_tx_start,                      // Inicio de la transmicion
    output [DATA_SIZE - 1 : 0] o_tx,        // Dato a transmitir
    output [DATA_SIZE - 1 : 0] o_data_a,   
    output [DATA_SIZE - 1 : 0] o_data_b,
    output [OPCODE_SIZE - 1 : 0] o_opcode
);
    // Estados
    localparam read_a  = 2'b00;
    localparam read_b  = 2'b01;
    localparam read_op = 2'b10;
    localparam result  = 2'b11;

    reg [1 : 0] state_reg, state_next;

    reg tx_reg, tx_next;
    reg [DATA_SIZE - 1 : 0] result_reg, result_next;
    reg [DATA_SIZE - 1 : 0] data_a_reg, data_a_next;
    reg [DATA_SIZE - 1 : 0] data_b_reg, data_b_next;
    reg [OPCODE_SIZE - 1 : 0] opcode_reg, opcode_next;


    // Estados
        always @(posedge i_clk) begin
        if (i_reset) begin
            state_reg <= read_a;
            result_reg <= 0;
            data_a_reg <= 0;
            data_b_reg <= 0;
            opcode_reg <= 0;
            tx_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            result_reg <= result_next;
            data_a_reg <= data_a_next;
            data_b_reg <= data_b_next;
            opcode_reg <= opcode_next;
            tx_reg <= tx_next;
        end
    end

     always @(*) begin
        state_next  = state_reg;
        result_next = result_reg;
        data_a_next = data_a_reg;
        data_b_next = data_b_reg;
        opcode_next = opcode_reg;
        tx_next   = 1'b0;

        case (state_reg)

            read_a: begin
                if (i_read_done) begin
                    data_a_next = i_rx_data; // Escribe el ultimo bit        
                    state_next = read_b;     // Cambio de estado
                end
            end

            read_b: begin
                if (i_read_done) begin
                    data_b_next = i_rx_data;        
                    state_next = read_op;
                end
            end

            read_op: begin
                if (i_read_done) begin
                    opcode_next = i_rx_data[OPCODE_SIZE - 1: 0];        
                    state_next = result;
                end
            end

            result: begin
                result_next = i_alu_result; // Guarda el resultado de la operacion
                tx_next = 1'b1;             // Avisa a Tx para transmitir
                state_next = read_a;        // Resetea al primer estado
            end

            default: begin
                state_next = read_a;
            end
    endcase
    end

    // OUTPUTS
    assign o_tx_start = tx_reg;
    assign o_tx = result_reg;
    assign o_data_a = data_a_reg;
    assign o_data_b = data_b_reg;
    assign o_opcode = opcode_reg;

endmodule