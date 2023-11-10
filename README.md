# RISC_processor

This repo contains the verilog code of a 32-bit processor designed following the RISC architecture . The detailed decription of the processor can be found in CPU-specs-final.docx.pdf document.
A more detailed description of the data path and instruction encoding is provided in the 32 Bit Processor Design (1)..pdf file .


The code currently has the instructions to run a GCD algorithm and Bubble sort algorithm (Only one of the two algorithm can be used at a time , uncomment the required parts in the initial block of main.v to use it. )

## How to run 
- Make sure to have  the icarus-verilog dependency installed before running this code .
- If that is installed then compile the code by running `iverilog testbench.v` 
- This will generate the a.out file of the code .
- You can run it with the command `vvp ./a.out` 

## how to add Your own instructions
- Any other algorithm that is in the scope of this processor can be simulated .
- In order to do it , follow the instruction encoding procedure followed in the 32 Bit Processor Design (1)..pdf file and accordingly write the machine code inside the instruction memory ( can be found in the initial block of the main.v file)
- **Note** that the first instruction is a garbage instruction (needed to stall the CPU - you may use the same one that is already there) and the last instruction is a termination instruction (which also you can use the one that is already there)


