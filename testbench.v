`include "main.v"

module tb();

reg clk,rst,halt_button;

always forever begin
    #100 clk = ~clk;
end

CPU DUT(clk, rst, halt_button);

initial begin
    clk = 0;

    $monitor("PC: %d,Reg_Values (R0-R7): %d %d %d %d %d %d %d %d",DUT.PC ,DUT.RB.R0.data, DUT.RB.R1.data, DUT.RB.R2.data, DUT.RB.R3.data, DUT.RB.R4.data, DUT.RB.R5.data, DUT.RB.R6.data, DUT.RB.R7.data);
    
    #100 rst=1;
    #100 rst=0;
    halt_button=0;
    #2000 $finish;
end

endmodule