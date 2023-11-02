module ADDER(clk,a,op2,cin,sum,cout);
    input wire clk;
    input wire[31:0] a;
    input wire[31:0] op2;
    input wire cin;
    output reg[31:0] sum;
    output reg cout;
    wire [31:0] b;
    assign b =op2;
    reg [32:0] carry;  // contains all the carry outs at each bit
    reg [31:0] G;     //  generate signals
    reg [31:0] P;     // Propagate signal

    always@(*)begin
        G = a&b;
        P = a^b;


        // Carry Look Ahead Addition (8-bit)
        carry[0] = cin;
        carry[1] = G[0] | (P[0] & carry[0]);
        carry[2] = G[1] | (P[1] & carry[1]);
        carry[3] = G[2] | (P[2] & carry[2]);
        carry[4] = G[3] | (P[3] & carry[3]);
        carry[5] = G[4] | (P[4] & carry[4]);
        carry[6] = G[5] | (P[5] & carry[5]);
        carry[7] = G[6] | (P[6] & carry[6]);
        carry[8] = G[7] | (P[7] & carry[7]);

        carry[9] = G[8] | (P[8] & carry[8]);
        carry[10] = G[9] | (P[9] & carry[9]);
        carry[11] = G[10] | (P[10] & carry[10]);
        carry[12] = G[11] | (P[11] & carry[11]);
        carry[13] = G[12] | (P[12] & carry[12]);
        carry[14] = G[13] | (P[13] & carry[13]);
        carry[15] = G[14] | (P[14] & carry[14]);
        carry[16] = G[15] | (P[15] & carry[15]);

        carry[17] = G[16] | (P[16] & carry[16]);
        carry[18] = G[17] | (P[17] & carry[17]);
        carry[19] = G[18] | (P[18] & carry[18]);
        carry[20] = G[19] | (P[19] & carry[19]);
        carry[21] = G[20] | (P[20] & carry[20]);
        carry[22] = G[21] | (P[21] & carry[21]);
        carry[23] = G[22] | (P[22] & carry[22]);
        carry[24] = G[23] | (P[23] & carry[23]);

        carry[25] = G[24] | (P[24] & carry[24]);
        carry[26] = G[25] | (P[25] & carry[25]);
        carry[27] = G[26] | (P[26] & carry[26]);
        carry[28] = G[27] | (P[27] & carry[27]);
        carry[29] = G[28] | (P[28] & carry[28]);
        carry[30] = G[29] | (P[29] & carry[29]);
        carry[31] = G[30] | (P[30] & carry[30]);
        carry[32] = G[31] | (P[31] & carry[31]);
        
        sum = a^b^carry[31:0];

        cout = carry[32];  //final carry out
        
    end
endmodule