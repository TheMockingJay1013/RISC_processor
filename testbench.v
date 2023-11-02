`include "top_top_level.v"

module tb();

reg clk, rp1, rp2, wp, w;
reg [3:0] ap1, ap2, apw;
reg [3:0] op;
reg [31:0] ext_write;
wire [31:0] R;

parameter ADD=0, SUB=1, AND=2, OR=3, XOR=4, NOT=5, SLA=6, SRA=7, SRL=8;

alu_reg_bank DUT (clk, op, rp1, rp2, wp, w, ap1, ap2, apw, ext_write, R);

always forever begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;

    $monitor("R = %d ; Reg_Values (R0-R7): %d %d %d %d %d %d %d %d", R, DUT.RB.R0.data, DUT.RB.R1.data, DUT.RB.R2.data, DUT.RB.R3.data, DUT.RB.R4.data, DUT.RB.R5.data, DUT.RB.R6.data, DUT.RB.R7.data);

    #20
    w = 1; wp = 1;
    apw = 0;
    ext_write = 14;

    #20
    w = 1; wp = 1;
    apw = 1;
    ext_write = 25;

    #20
    rp1 = 1; rp2 = 1; wp = 0; w = 0;
    ap1 = 0; ap2 = 0;
    op = ADD;

    #20
    rp1 = 1; rp2 = 1; wp = 0; w = 0;
    ap1 = 1; ap2 = 0;
    op = SUB;

    #20
    rp1 = 1; rp2 = 1; wp = 1; w = 0;
    ap1 = 1; ap2 = 0; apw = 2;
    op = AND;

    #20
    rp1 = 0; rp2 = 0; wp = 1; w = 1;
    apw = 7;
    ext_write = 56;

    #20
    rp1 = 1; rp2 = 1; wp = 1; w = 0;
    ap1 = 2; ap2 = 1; apw = 4;
    op = SLA;

    #100
    $finish;
end

endmodule