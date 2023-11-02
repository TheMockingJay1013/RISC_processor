module SRL(clk,op1,op2,result);
    input clk ;
    input [31:0] op1;
    input [31:0]op2;
    output integer result;

    always @(posedge clk)
        
        begin
            result = op1 >> op2[0];
        end
endmodule