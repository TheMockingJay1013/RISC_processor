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
    input halt_button 
); 

reg [WIDTH-1:0] memory [0:MEM_SIZE-1] ;
reg [WIDTH-1:0] data_memory [0:MEM_SIZE-1] ;
// stack pointer
reg [PC_SIZE-1:0] SP;

reg [PC_SIZE-1:0] PC,NPC;               // note : since we use 1d array memory , PC needs to incremented by 1 not 4

reg [WIDTH-1:0] IR;

reg [WIDTH-1:0] A,B;
reg [15:0] Imm1; 
reg [22:0] Imm2;

reg [3:0] rs,rt,rd ;


reg [2:0] opcode; 

// opcode is the first 3 bits of IR





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
reg clk2;
// register bank
reg read_port_1, read_port_2, write_port;
reg [3:0] addr_port_1, addr_port_2, addr_port_write;
reg [WIDTH-1:0] din_port_write;
wire [WIDTH-1:0] dout_port_1, dout_port_2;



register_bank RB (clk2, read_port_1, read_port_2, write_port, addr_port_1, addr_port_2, addr_port_write, din_port_write, dout_port_1, dout_port_2);



// ALU

wire [WIDTH-1:0] op1, op2;
reg [3:0] alu_op;
wire [WIDTH-1:0] result;

ALUtoplevel DUTALU(clk2, op1, op2, alu_op, result );

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




always forever begin
    #5 clk2 = ~clk2;
end

initial
    begin
        clk2 = 0;
        state = FETCH;
        PC = 0;
        SP = 32'b00000000000000000000001111111111;
        memory[0] = 32'b00011111111101100000000000000000;   // random instr bcz of weird bug
        // // memory[1] = 32'b00011111111011000000000000000000;   // random instr bcz of weird bug
        // memory[1] = 32'b00000000001001000000000000000001;  // sub R2,R0,R1
        // memory[2] = 32'b00000000001001100000000000000110;   // sla R3,R0,R1
        // memory[3] = 32'b00000000010000000000000010011000;   // addi R2,R0,4
        // memory[4] = 32'b00100000010000000000000000000001;   // ST R2,0(R0)
        // memory[5] = 32'b00100000100000000000000000000000;   // LD R4,0(R0)
        // // memory[6] = 32'b10000100000000000000000000000000;   // mov R1,R2
        // // memory[6] = 32'b01000101111111111111111111110110;   // BPL R2,#-3
        // // memory[6] = 32'b01000101111111111111111111110101;   // BMI R2,#-3
        // // memory[6] = 32'b01000001111111111111111111110100;   // BR #-3
        // memory[6] = 32'b11000000000000000000000000110001;      // SUBI SP,#1
        // memory[7] = 32'b11111111111111111111111111111111;   // terminate


        // GCD code
        memory[1] = {11'b00001100000, 16'b0000000000001101, 5'b10000};       // addi R0,R6,4
        memory[2] = {11'b00001100001, 16'b0000000000110100, 5'b10000};       // addi R1,R6,2   
        memory[3] = 32'b00000000001010100000000000000001;                    // sub R5,R0,R1  
        memory[4] = 32'b01001010000000000000000000101011;                    // beq R5 #10
        memory[5] = 32'b01001010000000000000000000001010;                    // bgt R5 #2     
        memory[6] = 32'b01001010000000000000000000010001;                    // blt R5 #4
        memory[7] = 32'b00000000001011000000000000000001;                    // sub R6,R0,R1 
        memory[8] = 32'b10001100000000000000000000000000;                    // mov R0,R6
        memory[9] = 32'b01011111111111111111111111101000;                    // br #-6
        memory[10] =32'b10000000010000000000000000000000;                    // mov R2,R0
        memory[11] =32'b10000010000000000000000000000000;                    // mov R0,R1
        memory[12] =32'b10000100001000000000000000000000;                    // moc R1,R2
        memory[13] =32'b01011111111111111111111111011000;                    // br -10
        memory[14] =32'b11111111111111111111111111111111;                    // terminate
        read_port_1 = 0;
        read_port_2 = 0;
    end


// state transition logic
 // change state based on the current state

always @(posedge clk)
begin
    if(rst)
        begin
            state = FETCH;
            PC = 0;
        end
    else begin
    case(state)
        FETCH : 
            begin
                write_port = 0;
                IR = memory[PC];
                opcode = IR[31:29];
                NPC = PC + 1;
                state = DECODE;
                // $display("State : FETCH");
            end

        DECODE :
            begin
                // $display("State : DECODE");
                case(opcode)
                    3'b000 : begin                                                         // ALU instruction 
                                funct = IR[4:0];
                                rs = IR[28:25];
                                rt = IR[24:21];
                                rd = IR[20:17];
                                Imm1 = IR[20:5];

                                alu_op = funct[2:0] ;
                                MUXALU1_sel = 0;
                                MUXALU2_sel = funct[4];
                                // sign extend imm1 and store in immediate
                                if(Imm1[15] == 1)
                                    Immediate = {16'b1111111111111111,Imm1};
                                else
                                    Immediate = {16'b0000000000000000,Imm1};
                                
                                //accesing data from register bank
                                // write_port = 1;
                                addr_port_1 = rs;
                                addr_port_2 = (funct[4])?4'bz:rt;
                                read_port_1 = 1;
                                read_port_2 = 1;
                                addr_port_write = (funct[4])?rt:rd;


                                
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
                            addr_port_1 = rs ;
                            addr_port_2 = rt ;
                            read_port_1 = 1 ;
                            read_port_2 = 1 ;
                            addr_port_write = rt ;
                            alu_op = 0 ;
                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;


                           

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

                            read_port_1 = 1;
                            addr_port_1 = rs ;
                            

                            MUXALU1_sel  = 1;
                            MUXALU2_sel = 1 ;
                            alu_op = 0;
                            cond = funct2 ;
                    

                    
                        end
                    3'b011 :                                                      // stack 
                        begin
                            
                            funct = IR[1:0] ;
                            Immediate = 32'b0 ;

                            alu_op = 0 ;
                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;

                        end
                    
                    3'b100 :                                                        // move instr
                        begin
                            rs = IR[28:25];
                            rt = IR[24:21];

                            Immediate = 32'b0;

                            addr_port_1 = rs ;
                            read_port_1 =1 ;

                            addr_port_write = rt ;

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

                            

                            alu_op = funct[3:0] ;
                            MUXALU1_sel = 0;
                            MUXALU2_sel = 1;
                            

                        end
                    3'b111 :
                        begin
                            state = TERMINATION;
                        end

                endcase

                if(opcode == 3'b101 && program_control_op == 0 && halt_button == 1) state = DECODE;
                else if(opcode == 3'b111) state = TERMINATION;
                else state = EXECUTE;
            end
        EXECUTE :
            begin
                // $display("State : EXECUTE");
                case(opcode)
                    3'b000 :
                        begin
                            A= dout_port_1;
                            B = dout_port_2;
                            // ALU_out = result;
                            // din_port_write = ALU_out;
                            

                        end

                    3'b001 :
                        begin
                            A = (funct[2:0]==3'b101) ? SP : dout_port_1;
                            B =(funct[3:0]==4'b0011) ? SP : dout_port_2 ;
                            if(funct[3:0] == 4'b1101) B = NPC ;
                            ALU_out = result ;
                        end

                    3'b010 :
                        begin
                            A = dout_port_1 ;
                            ALU_out = result ;
                            // cond = funct2 ;


                        end
                    3'b011:
                        begin
                            A = SP ;
                            ALU_out = result ;
                        end
                    
                    3'b100 :
                        begin
                            A = dout_port_1 ;
                            
                        end
                    
                    3'b110 :
                        begin
                            A = SP ;
                            
                        end


                endcase
                
                state = MEMORY;
            end
        
        MEMORY :
            begin
                // $display("State : MEMORY");
                case(opcode)
                    3'b000 :
                        begin
                            PC = NPC;
                            ALU_out = result;
                            din_port_write = ALU_out;
                            write_port = 1;
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
                            PC = data_memory[ALU_out];
                        end
                    
                    3'b100 :
                        begin
                            PC = NPC;
                            ALU_out = result;
                            din_port_write = ALU_out;
                        end
                    
                    3'b101 :
                        begin
                            PC = NPC;
                        end

                    3'b110 :
                        begin
                            PC = NPC;
                            ALU_out = result;
                        end
                    
                endcase
                state = WRITEBACK;
            end
        WRITEBACK :
            begin
                // $display("State : WRITEBACK");
                case(opcode)
                    3'b000 :
                        begin
                            din_port_write = ALU_out;
                            
                        end
                    3'b001:
                        begin
                            case(funct[1:0])
                                2'b00 : 
                                    begin
                                        
                                        din_port_write = LMD ;
                                        write_port = 1 ;
                                    end

                                2'b10 : 
                                    begin
                                        din_port_write = LMD ;
                                        write_port =1 ;
                                    end
                            endcase

                        end
                    3'b010 :
                        begin

                        end
                    
                    3'b100 :
                        begin
                            write_port = 1;
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
end


endmodule