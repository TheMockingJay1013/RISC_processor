// include the modules

module SUBTRACTOR(
    input wire clk,
    input wire[31:0] a,
    input wire[31:0] op2,
    output reg[31:0] diff,
    output reg Cout
);

    /*
        1.First find the 2's complement of b (the second input)
        2. Add the first input (a) snd the 2's complement of b(found in the first step)
        3.  If carry out in the second step is 1 then the answer is positive and there is no need to do anything
            else if the carry out is 0 this means that the answer is negative we take 2's complement of the result and return it

            
            it is assumed that a>b 
    */
    wire [31:0]b;
    assign b =op2;
    wire [31:0] b_1comp;
    reg [31:0] b_2comp;
    wire [31:0] temp_diff;
    wire cout;

    ADDER DIFF (clk,a,b_2comp,1'b0,temp_diff,cout);  // call to adder

    always@(*)begin
        
        b_2comp = (~b)+ 32'b00000000000000000000000000000001; //2's complement of b
        diff =temp_diff ;//check if result is negative and make the changes accordingly
        if(b==32'b00000000000000000000000000000000)begin 
            Cout=1;
        end 
        else Cout=cout;
    end

endmodule