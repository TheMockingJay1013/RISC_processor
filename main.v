`include "register_bank.v"
`include "ALU_TOP_LEVEL.v"
`include "datapath_modules.v"


// module memory #(parameter WIDTH=32, parameter MEM_SIZE=1024)
// (
//     input clk ,
//     input rst ,
//     input [WIDTH-1:0] din ,
//     input [MEM_SIZE-1:0] addr ,
//     input writemem ,
//     output [WIDTH-1:0] dout
// );

// reg [WIDTH-1:0] memory [0:MEM_SIZE-1] ;

// assign dout = (writemem == 1'b0) ? memory[addr] : 0;

// always @(posedge clk)
// begin
//     if(rst)
//         begin
//             memory[addr] <= 0;
//         end
//     else if(write)
//         begin
//             memory[addr] <= din;
//         end
// end

// endmodule


module CPU #(parameter WIDTH=32, parameter MEM_SIZE=1024,parameter PC_SIZE=32)
(
    input clk ,
    input rst ,
    input halt_button ,
    input [WIDTH-1:0] memory [0:MEM_SIZE-1] 

); 

reg [WIDTH-1:0] data_memory [0:MEM_SIZE-1] ;
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
//uses imm1 for immediate value
//uses funct for the type of ALU instruction
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

reg [WIDTH-1 : 0] LMD ;                                // taking the data read from memory


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

MUX_2x1 MUXALU1 ( MUXALU1_sel, A, PC , MUXALU1_out);
assign op1 = MUXALU1_out;


//MUXALU2
reg MUXALU2_sel;
wire [WIDTH-1:0] MUXALU2_out;

MUX_2x1 MUXALU2 ( MUXALU2_sel, B, Immediate , MUXALU2_out);
assign op2 = MUXALU2_out;

//CONDITION check module
reg [1:0] cond ;
wire cond_out ;
condition_check checker(A,cond,cond_out);

/*----------------------------------------------------------------------------------------------------------------*/

// parameters for the 5 states of the CPU
/*----------------------------------------------------------------------------------------------------------------*/

parameter FETCH=0,DECODE=1,EXECUTE=2, MEMORY=3,WRITEBACK=4,TERMINATION=5;

// state register
reg [2:0] state;

/*----------------------------------------------------------------------------------------------------------------*/



initial
    begin
        state = FETCH;
        PC = 0;
    end


// state transition logic
always @(posedge clk)
begin
    if(rst)
        begin
            state = FETCH;
            PC = 0;
        end
    case(state)
        FETCH : 
            begin
                write_port = 0;
                IR = memory[PC];
                NPC = PC + 1;
                state = DECODE;
            end

        DECODE :
            begin
                case(opcode)
                    3'b000 : begin                                                         // ALU instruction 
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

                                MUXALU1_sel = 0;
                                MUXALU2_sel = funct[4];
                                alu_op = funct[2:0] ;
                            end
                    3'b001 :                                                              // load store instruction 
                        begin
                            funct=IR[4:0];
                            rs = IR[28:25];
                            rt = IR[24:21];
                            Imm1 = IR[20:5];
                            if(Imm1[15] == 1)
                                Immediate = {16'b1111111111111111,Imm1};
                            else
                                Immediate = {16'b0000000000000000,Imm1};

                            // accessing from reg bank 
                            read_port_1 = 1 ;
                            read_port_2 = 1 ;
                            addr_port_1 = rs ;
                            A = (funct[2]==0) ? dout_port_1 : SP ;
                            B =(funct[2]==0) ? dout_port_2 : SP ;
                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;
                            alu_op = 0 ;

                        end
                    3'b010 :                                                          // branch instr
                        begin
                            funct2 = IR[1:0];
                            rs= IR[28:25];
                            Imm2 = IR[24:2];
                            if(Imm2[22] == 1)
                                Immediate = {9'b111111111,Imm2};
                            else
                                Immediate = {9'b000000000,Imm2};

                            read_port_1 =1;
                            addr_port_1 = rs ;
                            A = dout_port_1 ;

                            MUXALU1_sel  = 1;
                            MUXALU2_sel = 1 ;
                            alu_op = 0;
                    

                    
                        end
                    3'b011 :                                                      // stack 
                        begin
                            

                        end
                    
                    3'b100 :                                                        // move instr
                        begin
                            rs = IR[28:25];
                            rt = IR[24:21];

                            Immediate = 0;

                            read_port_1 =1 ;
                            addr_port_1 = rs ;

                            A = dout_port_1 ;

                            alu_op = 0;
                            MUXALU1_sel = 0;
                            MUXALU2_sel =1;
                        end
                    3'b101:
                        begin
                            program_control_op = IR[28];
                            Immediate = 0;
                            alu_op = 0;
                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;

                        end
                    
                    3'b110:                                                      // Stack ALU 
                        begin
                            funct = IR[4:0];
                            Imm1 = IR[20:5];

                            // sign extend imm1 and store in immediate
                            if(Imm1[15] == 1)
                                Immediate = {16'b1111111111111111,Imm1};
                            else
                                Immediate = {16'b0000000000000000,Imm1};

                            A = SP ;

                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;
                            alu_op = funct[3:0] ;
                        end
                    3'b111 :
                        begin
                            state = TERMINATION;
                        end

                endcase

                state = EXECUTE;
                if(opcode == 3'b101 && program_control_op == 1 && halt_button == 1)
                    state = DECODE;
            end
        EXECUTE :
            begin
                read_port_1 = 0;
                read_port_2 = 0;
                case(opcode)
                    3'b000 :
                        begin
                            ALU_out = result;
                        end

                    3'b001 :
                        begin
                            ALU_out = result ;
                        end

                    3'b010 :
                        begin
                            ALU_out = result ;
                            cond = funct2 ;


                        end
                    3'b011:
                        begin
                            
                        end
                    
                    3'b100 :
                        begin
                            ALU_out = result;
                        end
                    
                    3'b110 :
                        begin
                            ALU_out = result;
                        end


                endcase
                
                state = MEMORY;
            end
        
        MEMORY :
            begin
                case(opcode)
                    3'b000 :
                        begin
                            PC = NPC;
                        end
                    
                    3'b001 :
                        begin
                            case(funct[1:0])
                                2'b00 :
                                    begin
                                        LMD = data_memory[ALU_out];
                                    end
                                2'b01:
                                    begin
                                        data_memory[ALU_out] = B ;
                                    end
                                2'b10 :
                                    begin
                                        LMD = data_memory[ALU_out];
                                    end
                                2'b11:
                                    begin
                                        data_memory[ALU_out] = B ;
                                    end

                            endcase
                            PC = NPC ;
                        end

                    3'b010 :
                        begin
                            if(cond_out)
                                begin
                                    PC = ALU_out ;
                                end
                            else 
                                begin
                                    PC = NPC;
                                end
                        end
                    3'b011:
                        begin

                        end
                    
                    3'b100 :
                        begin
                            PC = NPC;
                        end
                    
                    3'b101 :
                        begin
                            PC = NPC;
                        end

                    3'b110 :
                        begin
                            PC = NPC;
                        end
                    
                endcase
                state = WRITEBACK;
            end
        WRITEBACK :
            begin
                case(opcode)
                    3'b000 :
                        begin
                            write_port = 1;
                            addr_port_write = (funct[4])? rt : rd;
                            din_port_write = ALU_out;
                        end
                    3'b001:
                        begin
                            case(funct[1:0])
                                2'b00 : 
                                    begin
                                        write_port =1 ;
                                        addr_port_write = rt ;
                                        din_port_write = LMD ;
                                    end

                                2'b10 : 
                                    begin
                                        write_port =1 ;
                                        addr_port_write = rt ;
                                        din_port_write = LMD ;
                                    end
                            endcase

                        end
                    
                    3'b100 :
                        begin
                            write_port = 1;
                            addr_port_write = rt ;
                            din_port_write = ALU_out;
                        end
                    3'b110 :
                        begin
                            SP = ALU_out;
                        end
                endcase
                state = FETCH ;
            end
        TERMINATION :
            begin
                state = TERMINATION;
            end
    endcase
end


endmodule