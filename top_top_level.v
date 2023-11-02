`include "register_bank.v"
`include "ALU_TOP_LEVEL.v"

module alu_reg_bank #(parameter ADDR_WIDTH = 4, WIDTH = 32)
(
    input clk,
    input [3:0] alu_op,
    input read_port_1, read_port_2, write_port, W,
    input [ADDR_WIDTH-1:0] addr_port_1, addr_port_2, addr_port_write,
    input [WIDTH-1:0] external_write,
    output [WIDTH-1:0] R
);

wire [WIDTH-1:0] A, B, write_data;

assign write_data = (W == 1) ? external_write : R;

register_bank RB (clk, read_port_1, read_port_2, write_port, addr_port_1, addr_port_2, addr_port_write, write_data, A, B);
ALUtoplevel DUTALU(clk, A, B, alu_op, R );

endmodule