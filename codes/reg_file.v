/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the register file implementation
*/

`timescale 1ns/100ps

//register file module
module reg_file (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET,busywait);
	
	reg [7:0] REGISTERS[7:0];//register array
	
	output wire  [7:0] OUT1, OUT2; //read the registers
	
	input[7:0] IN;//data write into the registers
	input[2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;//addresses of registers to read and write data
	
	input WRITE, CLK, RESET,busywait;
	
	
	integer i;
		
	assign #2 OUT1 = REGISTERS[OUT1ADDRESS] ;//reading from the registers is done continuously
	assign #2 OUT2 = REGISTERS[OUT2ADDRESS];
	
	always @(RESET)
	begin
	
		 #2 if (RESET)
		  begin
			 	 
			 for(i=0;i<8;i=i+1)
			begin
				 REGISTERS[i] <= 0;//resetting the registers
			end
		end
		
	end
	
	always @(posedge CLK)
	begin
		#1 if(WRITE && (!RESET) && (!busywait))
		begin
			 REGISTERS[INADDRESS] <= IN;//writing into registers
		end
		
	end	

endmodule
