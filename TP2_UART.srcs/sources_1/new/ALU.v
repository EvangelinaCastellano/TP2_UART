`timescale 1ns / 1ps

module ALU
#(
    parameter NB_IN         = 8, // Number of bits of the operands
    parameter NB_OUT        = 8, // Number of bits of the result
    parameter NB_OPERATION  = 6  // Number of bits of the operation
)
(
    input   [NB_IN - 1 : 0]         i_data_a,    // Operand A
    input   [NB_IN - 1 : 0]         i_data_b,    // Operand B
    input   [NB_OPERATION - 1 : 0]  i_operation, // Operation code
    output  [NB_OUT - 1 : 0]        o_data       // Result
);
    reg [NB_OUT - 1 : 0]        o_data_temp;

    assign o_data = o_data_temp;

always @(*)
    begin 
        case(i_operation)
            6'b100000: o_data_temp = i_data_a + i_data_b;                //ADD
            6'b100010: o_data_temp = i_data_a - i_data_b;                //SUB
            6'b100100: o_data_temp = i_data_a & i_data_b;                //AND
            6'b100101: o_data_temp = i_data_a | i_data_b;                //OR 
            6'b100110: o_data_temp = i_data_a ^ i_data_b;                //XOR
            6'b000011: o_data_temp = ($signed(i_data_a)) >>> i_data_b;   //SRA
            6'b000010: o_data_temp = i_data_a >> i_data_b;               //SRL
            6'b100111: o_data_temp = ~(i_data_a | i_data_b);             //NOR
            default: o_data_temp = {NB_OUT{1'b0}};                       //INVALID CODE
        endcase                                        
    end

endmodule