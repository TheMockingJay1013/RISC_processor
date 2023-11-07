module register #(parameter WIDTH = 32)
(
    input clk, rin, rout1, rout2,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout1, dout2
);

reg [WIDTH-1:0] data;

always @(posedge clk) begin
    if (rin) data <= din;

    if (rout1) dout1 <= data;
    else dout1 <= 32'bz;

    if (rout2) dout2 <= data;
    else dout2 <= 32'bz;

end

initial begin
    data <= 1;
end

endmodule

module addr_decoder_5x32
(
    input clk,
    input en,
    input [3:0] in,
    output reg [15:0] out
);

always @(posedge clk) begin
    if (en) begin
        case (in)
            4'b0000 : out <= {15'b0, 1'b1};
            4'b0001 : out <= {14'b0, 1'b1, 1'b0};
            4'b0010 : out <= {13'b0, 1'b1, 2'b0};
            4'b0011 : out <= {12'b0, 1'b1, 3'b0};
            4'b0100 : out <= {11'b0, 1'b1, 4'b0};
            4'b0101 : out <= {10'b0, 1'b1, 5'b0};
            4'b0110 : out <= {9'b0, 1'b1, 6'b0};
            4'b0111 : out <= {8'b0, 1'b1, 7'b0};
            4'b1000 : out <= {7'b0, 1'b1, 8'b0};
            4'b1001 : out <= {6'b0, 1'b1, 9'b0};
            4'b1010 : out <= {5'b0, 1'b1, 10'b0};
            4'b1011 : out <= {4'b0, 1'b1, 11'b0};
            4'b1100 : out <= {3'b0, 1'b1, 12'b0};
            4'b1101 : out <= {2'b0, 1'b1, 13'b0};
            4'b1110 : out <= {1'b0, 1'b1, 14'b0};
            4'b1111 : out <= { 1'b1, 15'b0};
        endcase
    end
    else 
        begin   
            out <= 16'bz;
        end

end

endmodule


module register_bank #(parameter ADDR_WIDTH = 4, WIDTH = 32)
(
    input clk,
    input read_port_1, read_port_2, write_port,
    input [ADDR_WIDTH-1:0] addr_port_1, addr_port_2, addr_port_write,
    input [WIDTH-1:0] din_port_write,
    output [WIDTH-1:0] dout_port_1, dout_port_2
);

wire [15:0] rin, rout1, rout2;

addr_decoder_5x32 D1 (clk,read_port_1, addr_port_1, rout1);
addr_decoder_5x32 D2 (clk,read_port_2, addr_port_2, rout2);
addr_decoder_5x32 D3 (clk,write_port, addr_port_write, rin);


register R0 (clk, rin[0], rout1[0], rout2[0], din_port_write, dout_port_1, dout_port_2);
register R1 (clk, rin[1], rout1[1], rout2[1], din_port_write, dout_port_1, dout_port_2);
register R2 (clk, rin[2], rout1[2], rout2[2], din_port_write, dout_port_1, dout_port_2);
register R3 (clk, rin[3], rout1[3], rout2[3], din_port_write, dout_port_1, dout_port_2);
register R4 (clk, rin[4], rout1[4], rout2[4], din_port_write, dout_port_1, dout_port_2);
register R5 (clk, rin[5], rout1[5], rout2[5], din_port_write, dout_port_1, dout_port_2);
register R6 (clk, rin[6], rout1[6], rout2[6], din_port_write, dout_port_1, dout_port_2);
register R7 (clk, rin[7], rout1[7], rout2[7], din_port_write, dout_port_1, dout_port_2);
register R8 (clk, rin[8], rout1[8], rout2[8], din_port_write, dout_port_1, dout_port_2);
register R9 (clk, rin[9], rout1[9], rout2[9], din_port_write, dout_port_1, dout_port_2);
register R10 (clk, rin[10], rout1[10], rout2[10], din_port_write, dout_port_1, dout_port_2);
register R11 (clk, rin[11], rout1[11], rout2[11], din_port_write, dout_port_1, dout_port_2);
register R12 (clk, rin[12], rout1[12], rout2[12], din_port_write, dout_port_1, dout_port_2);
register R13 (clk, rin[13], rout1[13], rout2[13], din_port_write, dout_port_1, dout_port_2);
register R14 (clk, rin[14], rout1[14], rout2[14], din_port_write, dout_port_1, dout_port_2);
register R15 (clk, rin[15], rout1[15], rout2[15], din_port_write, dout_port_1, dout_port_2);

always @(posedge clk) begin
    $display("D1.out: %b, D2.out: %b, D3.out: %b", D1.out, D2.out, D3.out);
end
endmodule
