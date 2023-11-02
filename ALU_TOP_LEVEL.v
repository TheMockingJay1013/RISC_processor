
// include the modules
`include "AND.v"
`include "OR.v"
`include "XOR.v"
`include "NOT.v"
`include "SLA.v"
`include "SRA.v"
`include "SRL.v"
`include "ADDER.v"
`include "SUBTRACTOR.v"


module ALUtoplevel(
    clk,
    op1,
    op2,
    alu_op,
    result 
);
    input clk ;

    input [31:0] op1 ;
    input [31:0] op2 ;
    input [3:0] alu_op ;

    output  result ;
    integer result ;
    

    wire [31:0] and_out ;
    wire [31:0] or_out ;
    wire[31:0] not_out;
    wire [31:0] xor_out ;
    wire[31:0] sla_out ;
    wire[31:0]sra_out ;
    wire [31:0] srl_out ;
    wire[31:0]add_out;
    wire add_cout;
    wire[31:0]sub_out;
    wire sub_cout;

    AND ANDOP(clk,op1,op2,and_out);
    OR OROP(clk,op1,op2,or_out);
    XOR XOROP(clk,op1,op2,xor_out);
    NOT NOTOP(clk,op1,not_out);
    SLA SLAOP(clk,op1,op2,sla_out);
    SRA SRAOP(clk,op1,op2,sra_out);
    SRL SRLOP(clk,op1,op2,srl_out);
    ADDER ADDEROP(clk,op1,op2,1'b0,add_out,add_cout);
    SUBTRACTOR SUBTRACTOROP(clk,op1,op2,sub_out,sub_cout);

    always @(posedge clk) begin


            
            case(alu_op)
                4'b0000: result <= add_out ;
                4'b0001: result <= sub_out ;
                4'b0010: result <= and_out ;
                4'b0011: result <= or_out ;
                4'b0100: result <= xor_out ;
                4'b0101: result <= not_out ;
                4'b0110: result <= sla_out ;
                4'b0111: result <= sra_out ;
                4'b1000: result <= srl_out ;  

            endcase
    end

endmodule