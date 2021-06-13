/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the test bench to find whether our cpu is working correctly
*/

`include "cpu.v"//cpu
`include "data_cache.v"//cache memory
`include "data_memory.v"//data memory
`include "instruction_mem.v"//instruction memory
`include "instruction_cache.v"//instruction cache


`timescale 1ns/100ps

//testbench
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    wire READ,WRITE,BUSYWAIT;
    wire[7:0] ADDRESS,WRITEDATA,READDATA;
    
    
    wire[31:0] mem_writedata;
	wire[5:0] mem_address;
	wire mem_read,mem_write;
	wire[31:0] mem_readdata;
	wire mem_busywait;
	
	
	wire imem_busywait;
	wire imem_read;
	wire[127:0] imem_readdata;
	wire[5:0] imem_address;
	
	//icread is to read the instruction memory
	//other wait signals are the busywait signals for cache and data memory
	wire icread,data_cache_wait,instruction_cache_wait;
    
  
    /* 
    -----
     CPU
    -----
    */
    //cpu is instantaited here
    cpu mycpu(READ,WRITE,ADDRESS,WRITEDATA,PC, INSTRUCTION, CLK, RESET,READDATA,BUSYWAIT, icread);
    
    //cache memory is instantiated here
    dcache  dcache_mem(CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,data_cache_wait,mem_busywait,mem_readdata, mem_read, mem_write , mem_writedata, mem_address);
    
    //instatiating the data_memory in the  cache
	data_memory DataMem(CLK,RESET, mem_read,mem_write,mem_address, mem_writedata,mem_readdata,mem_busywait);
	
	//instruction memory read
	instruction_memory insmem(CLK, imem_read, imem_address, imem_readdata, imem_busywait);
	
	//instruction cache
	icache  inscache(CLK , RESET ,icread, PC , INSTRUCTION , instruction_cache_wait , imem_read , imem_address , imem_readdata , imem_busywait);
	
	//busywait to cpu 
	assign BUSYWAIT = data_cache_wait | instruction_cache_wait;
	

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b1;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #1
        RESET = 1'b1;
        
        #3
        RESET = 1'b0;
        
        
        // finish simulation after some time
        #2700
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule

