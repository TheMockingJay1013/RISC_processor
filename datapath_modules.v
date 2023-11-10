module MUX_2x1 #(parameter WIDTH = 32)
(
    input select ,
    input [WIDTH-1:0] in0 ,
    input [WIDTH-1:0] in1 ,
    output [WIDTH-1:0] out
);

assign out = (select == 1'b0) ? in0 : in1;


endmodule


module condition_check #(parameter width = 32)
(
    input [width-1:0] A ,
    input [1:0] cond ,
    output outp
);

parameter less = 1 , equal = 3 , greater = 2 ;

assign outp = (cond==0)? 1:(cond == less) ? (A[width-1] == 1) : (cond == equal) ? (A == 0) : (A[width-1] == 0) ;


endmodule

