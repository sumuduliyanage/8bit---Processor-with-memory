/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of the cpu.
*/



//needed module files are addded

`include "twos_complement.v"
`include "pc_adder.v"
`include "mux.v"
`include "reg_file.v"
`include "alu.v"
`include "branch.v"
`include "bne.v"
`include "mem_address.v"
`include "mem_writedata.v"

`timescale 1ns/100ps

//cpu module
module cpu(READENABLE_MEM,WRITEENABLE_MEM,MEM_ADDRESS,MEM_WRITEDATA,PC, INSTRUCTION, CLK, RESET,MEM_READDATA,MEM_BUSYWAIT,instruction_memread);

	input[31:0] INSTRUCTION;//fetched instructions
	input CLK,RESET,MEM_BUSYWAIT;
	input [7:0] MEM_READDATA;
	
	output[31:0] PC;//program counter
	output[7:0] MEM_ADDRESS,MEM_WRITEDATA;//outputs of cpu-they are inputs to the  data memory module
	output READENABLE_MEM,WRITEENABLE_MEM;//outputs of cpu-they are inputs to the data memory module
	
	reg READENABLE_MEM,WRITEENABLE_MEM;//control signals
	
	reg[7:0] OPCODE;//opcode 
	reg[7:0] DESTINATION;//destination register
	reg[7:0] SOURCE1;//source one has the register value to read
	reg[7:0] SOURCE2;//register or an immediate value
	
	reg NEG_SELECT,IMMEDIATE_SELECT,WRITE,BRANCH_SELECT,JUMP_SELECT,BNE_SELECT;//here we have select signals
	reg[2:0] ALUOP;//select signal for alu
	
	reg[2:0] READREG1;//from source 1
	reg[2:0] READREG2;//from source 2
	reg[2:0] WRITEREG;//from destination
	
	wire[7:0] DATA1;//data1 goes as an operand to alu
	wire[7:0] OUT2;//register read out 2
	wire[7:0] NEGOUT2;//output from the twos complement
	wire[7:0] REGRESULT;//regsiter readout 1
	wire[7:0] DATA2;//second operand for alu
	wire[7:0] IN;//out from the alu and wite into register file
	wire[7:0] ALU_RESULT;
	wire ISZERO,DOBRANCH,DOBNE;//these are also select signals
	
	output reg instruction_memread;
	//generating the instruction memory read signal
	always @(PC)
	begin
		if (PC == -4)
			instruction_memread = 0;
		else 
			instruction_memread = 1;
	end
	
	
	pc_update_adder pcadder(PC,PC,CLK,RESET,DOBRANCH,JUMP_SELECT,DOBNE,INSTRUCTION[23:16],MEM_BUSYWAIT);//pc is updated
	
	
	
	//DECODING THE INSTRUCTION
	//it takes a time delay of 1
	always @(INSTRUCTION)
	begin
		
		
		 OPCODE = INSTRUCTION[31:24];//instruction is decoded
		 DESTINATION = INSTRUCTION[23:16];
		 SOURCE1 = INSTRUCTION[15:8];
		 SOURCE2 = INSTRUCTION[7:0];
		 
		 READREG1 = INSTRUCTION[10:8];//register file inputs
		 READREG2 = INSTRUCTION[2:0];
		 WRITEREG =  INSTRUCTION[18:16];
		 
		 READENABLE_MEM = 1'b0;//they are initialized to zero
		 WRITEENABLE_MEM = 1'b0;
		 	 
		 	
		
		#1 if (OPCODE == 8'b00000000)//loadi
		begin
			IMMEDIATE_SELECT = 1'b1;// second operand is an immediate
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for loadi
			WRITE = 1'b1;//write is enabled
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000001)//mov
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for mov
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000010)//add
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b0;
			ALUOP = 3'b001;
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000011)//sub
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b1;
			ALUOP = 3'b001;
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000100)//and
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b0;
			ALUOP = 3'b010;
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000101)//or
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b0;
			ALUOP = 3'b011;
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00000111)//beq
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b1;//there is no negative value
			ALUOP = 3'b001;//
			WRITE = 1'b0;
			BRANCH_SELECT = 1'b1;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if(OPCODE == 8'b00000110)//jump
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b0;//there is no negative value
			WRITE = 1'b0;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b1;
			ALUOP = 3'bxxx;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00001000)//bne
		begin
			IMMEDIATE_SELECT = 1'b0;//source  2 is a register
			NEG_SELECT = 1'b1;//there is no negative value
			ALUOP = 3'b001;//substract
			WRITE = 1'b0;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b1;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		else if (OPCODE == 8'b00001001)//sll
		begin
			IMMEDIATE_SELECT = 1'b1;//source  2 is a register
			NEG_SELECT = 1'b0;//there is no negative value
			ALUOP = 3'b100;//substract
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		
		else if (OPCODE == 8'b00001010)//srl
		begin
			IMMEDIATE_SELECT = 1'b1;//source  2 is a register
			NEG_SELECT = 1'b0;//there is no negative value
			ALUOP = 3'b101;//substract
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		
		else if (OPCODE == 8'b00001011)//sra
		begin
			IMMEDIATE_SELECT = 1'b1;//source  2 is a register
			NEG_SELECT = 1'b0;//there is no negative value
			ALUOP = 3'b110;//substract
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		
		else if (OPCODE == 8'b00001100)//ror
		begin
			IMMEDIATE_SELECT = 1'b1;//source  2 is a register
			NEG_SELECT = 1'b0;//there is no negative value
			ALUOP = 3'b111;//substract
			WRITE = 1'b1;
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b0;
		end
		
		else if(OPCODE == 8'b00001101)//lwd
		begin
			IMMEDIATE_SELECT = 1'b0;// second operand is an immediate
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for loadi
			WRITE = 1'b1;//write is enabled
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b1;
			WRITEENABLE_MEM = 1'b0;
		end	
		
		else if (OPCODE == 8'b00001110)//lwi
		begin
			IMMEDIATE_SELECT = 1'b1;// second operand is an immediate
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for loadi
			WRITE = 1'b1;//write is enabled
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b1;
			WRITEENABLE_MEM = 1'b0;
		end
		
		else if (OPCODE == 8'b00001111)//swd
		begin
			IMMEDIATE_SELECT = 1'b0;// second operand is an immediate
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for loadi
			WRITE = 1'b0;//write is enabled
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b1;
		end
		
		else if (OPCODE == 8'b00010000)//swi
		begin
			IMMEDIATE_SELECT = 1'b1;// second operand is an immediate
			NEG_SELECT = 1'b0;
			ALUOP = 3'b000;//for loadi
			WRITE = 1'b0;//write is enabled
			BRANCH_SELECT = 1'b0;
			JUMP_SELECT = 1'b0;
			BNE_SELECT = 1'b0;
			READENABLE_MEM = 1'b0;
			WRITEENABLE_MEM = 1'b1;
		end
		
		else 
		begin
			WRITE = 1'b0;//when there is no instruction, write is disabled
			ALUOP = 3'bxxx;//aluop is also don't care
			BRANCH_SELECT = 1'bx;
			JUMP_SELECT = 1'bx;
			BNE_SELECT = 1'bx;
		end
				
		
	end
	
		//reading from the register file and writing into
		reg_file registerfile (IN, DATA1, OUT2, WRITEREG, READREG1, READREG2, WRITE, CLK, RESET,MEM_BUSYWAIT);
		
		//going to the the 2scomplement
		twos_complement twoscomplement(OUT2,NEGOUT2);
		
		//going to  multiplexer to check wether it is a substraction
		mux2_1  mux_substract(NEG_SELECT,OUT2,NEGOUT2,REGRESULT);
		
		
		//going to  mux and clarify whether the given value is an immediate value
		mux2_1 mux_immediate(IMMEDIATE_SELECT,REGRESULT,SOURCE2,DATA2);
		
		//instantiating the alu module
		alu Alu(DATA1, DATA2, ALU_RESULT, ALUOP,ISZERO);
		
		//this multiplexer will select whether we want to store the alu_result or data read from the memeory in to the reg file
		mux2_1 writereg_select(READENABLE_MEM,ALU_RESULT,MEM_READDATA,IN);
		
		 
		 //calling the branch module
		branch Branch(ISZERO, BRANCH_SELECT,DOBRANCH);
		 
		 //calling bne module to check whether DOBNE signal is high
		bne bne1(ISZERO,BNE_SELECT,DOBNE);
		
		//getting the address of the data memory
		mem_address Address_mem(ALU_RESULT,MEM_ADDRESS);
		
		//getting the data to write into the data memory	
		mem_writedata Mem_datawrite(DATA1,MEM_WRITEDATA);

	

endmodule






