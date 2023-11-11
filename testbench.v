`include "main.v"

module tb();

reg clk,rst,halt_button;

always forever begin
    #100 clk = ~clk;
end

CPU DUT(clk, rst, halt_button);

initial begin
    clk = 0;

    $monitor("SP: %d, PC: %d, Reg_Values (R0-R7): %d %d %d %d %d %d %d %d\n                                    Mem_Values[0:7] %d %d %d %d %d %d %d %d\n\n\n",DUT.SP,DUT.PC ,DUT.RB.R0.data, DUT.RB.R1.data, DUT.RB.R2.data, DUT.RB.R3.data, DUT.RB.R4.data, DUT.RB.R5.data, DUT.RB.R6.data, DUT.RB.R7.data,DUT.data_memory[0],DUT.data_memory[1],DUT.data_memory[2],DUT.data_memory[3],DUT.data_memory[4],DUT.data_memory[5],DUT.data_memory[6],DUT.data_memory[7]);
    
    #100 rst=1;
    #100 rst=0;
    halt_button=0;
    #20000000 $finish;
end

endmodule