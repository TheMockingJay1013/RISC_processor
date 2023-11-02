`include "register_bank.v"
`include "ALU_TOP_LEVEL.v"
`include "datapath_modules.v"



module CPU #(parameter WIDTH=32, parameter MEM_SIZE=256,parameter PC_SIZE=8)
(
    input clk ,
    input rst ,
    input [WIDTH-1:0] memory [0:MEM_SIZE-1] ,

);

// stack pointer
reg [PC_SIZE-1:0] SP;

reg [PC_SIZE-1:0] PC,NPC;               // note : since we use 1d array memory , PC needs to incremented by 1 not 4

reg [WIDTH-1:0] IR;

reg [WIDTH-1:0] A,B;
reg [15:0] Imm1; 
reg [22:0] Imm2;

reg [3:0] rs,rt,rd ;


wire [2:0] opcode; 

// opcode is the first 3 bits of IR
assign opcode = IR[31:29];




// special registers for diff instruction types 
/* ---------------------------------------------------------------------------------------------------------------------------------- */


// ALU instruction 
// uses rs ,rt and rd for register values
reg [4:0] funct ;

/* Load and store instructions 
Uses rs and rt for address calculation 
Uses same funct register as ALU instructions 
uses imm1 for the offset
*/


/* Branch instructions
uses rs and 23 bit imm2 for address calculation
Also uses a 2 bit funct2
*/
reg [1:0] funct2;


// Stack instruction 
// uses rs and 23 bit imm2 for address calculation
// uses funct2 for the type of stack instruction


// Move instruction
// uses rs and rt for register values

//Program Control instruction 
// uses a 1 bit operation variable to determine the type of instruction
reg program_control_op;

// Stack AlU instruction
// uses a 16 bit imm1 for the offset
// uses the same funct register as ALU instructions

/* ---------------------------------------------------------------------------------------------------------------------------------- */




// temporary registers for storing values
/*----------------------------------------------------------------------------------------------------------------*/

reg [WIDTH-1 :0] Immediate ;                           // for storing the sign extended value of imm1 or imm2 based on the instruction 



/*----------------------------------------------------------------------------------------------------------------*/


// The Modules Instantiation and declaration of required control signals
/*----------------------------------------------------------------------------------------------------------------*/

// register bank
reg read_port_1, read_port_2, write_port;
reg [3:0] addr_port_1, addr_port_2, addr_port_write;
reg [WIDTH-1:0] din_port_write;
wire [WIDTH-1:0] dout_port_1, dout_port_2;

register_bank RB (clk, read_port_1, read_port_2, write_port, addr_port_1, addr_port_2, addr_port_write, din_port_write, dout_port_1, dout_port_2);


// ALU

wire [WIDTH-1:0] op1, op2;
reg [3:0] alu_op;
wire [WIDTH-1:0] result;

ALUtoplevel DUTALU(clk, op1, op2, alu_op, result );

//register for storing ALU result 
reg [WIDTH-1:0] ALU_out;


//MUXALU1

reg MUXALU1_sel;
wire [WIDTH-1:0] MUXALU1_out;


/*----------------------------------------------------------------------------------------------------------------*/

// parameters for the 5 states of the CPU
/*----------------------------------------------------------------------------------------------------------------*/

parameter FETCH=0,DECODE=1,EXECUTE=2, MEMORY=3,WRITEBACK=4;

// state register
reg [2:0] state,next_state;

/*----------------------------------------------------------------------------------------------------------------*/



initial
    begin
        state = FETCH;
        PC = 0;
    end


// state transition logic
always @(posedge clk)
begin
    case(state)
        FETCH : 
            begin
                IR = memory[PC];
                NPC = PC + 1;
            end

        DECODE :
            begin
                case(opcode)
                    3'b000 : begin
                                funct = IR[4:0];
                                rs = IR[28:25];
                                rt = IR[24:21];
                                rd = IR[20:17];
                                Imm1 = IR[20:5];
                                // sign extend imm1 and store in immediate
                                if(Imm1[15] == 1)
                                    Immediate = {16'b1111111111111111,Imm1};
                                else
                                    Immediate = {16'b0000000000000000,Imm1};
                                
                                //accesing data from register bank
                                read_port_1 = 1;
                                read_port_2 = 1;
                                addr_port_1 = rs;
                                addr_port_2 = rt;
                                A = dout_port_1;
                                B = dout_port_2;
                                // setting write port to 0
                                write_port = 0;
                                addr_port_write = 0;


                                
                            end
                endcase
            end
        EXECUTE :
            begin

            end
        
        MEMORY :
            begin

            end
        WRITEBACK :
            begin

            end
    endcase
end


endmodule