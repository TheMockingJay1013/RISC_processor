module NOT(clk,op1,result);
    input clk ;
    input [31:0] op1;
    output integer result;

    always @(posedge clk)
    begin
        
        result = ~op1;
    end
endmodule