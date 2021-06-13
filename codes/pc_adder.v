/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of an adder to increment the pc
*/

//pc is updated and it also supports for the instructions like beq,bne,j 
//module to update the pc
/*here,we get the current pc value and calculate the next pc value....we have made seperate modules to do sign extending, multiplication by four,and adding the offset*/

`timescale 1ns/100ps

module pc_update_adder (current_pc,updated_pc,CLK,RESET,dobranch,isjump,dobne,offset,busywait);

	input signed[31:0] current_pc;//value of current pc
	input CLK,RESET;
	input dobranch,isjump,dobne,busywait;
	input signed[7:0] offset;
	
	output signed[31:0] updated_pc;
	reg signed[31:0] updated_pc;
	
	reg signed[31:0] default_pc;//value of upadated pc
	wire signed[31:0] branch_add;
	wire signed[31:0] y,z;
	
	always @(RESET)//when signal is reset 
	begin
		 if (RESET)
		begin
			#1 updated_pc = -32'd4;//when reset signal is 1, pc is going to -4
		end
	end
	
	
	always @(current_pc,updated_pc,posedge CLK,RESET,dobranch,isjump,dobne,offset,busywait)//wheen reset is not zero and not busy wait
	begin
		 if ((!RESET)&&(!busywait))
		begin
			
					#1 default_pc =  current_pc + 32'd4; 	//default pc is updated 
									
		end		
	end
	
	sign_extend signextender(offset,y);//sign extension is done
	multiply_4 mulby4(y,z);//then offset is multiplied by four
	new_adder newadd (default_pc,z,branch_add);//finally branch_add value is taken
	
	
	always @(posedge CLK)
	begin
		

		#1 if ((dobranch | isjump| dobne)&&(!busywait)&&(!RESET))//if user gives a jump instruction or working branch instruction, it is working
		begin
			updated_pc = branch_add;//jump and beq
		end
		else if ((!busywait)&&(!RESET))
		begin
			updated_pc = default_pc;//in normal situations
			  
		end
	
	end
	
	
	
	
endmodule


//this is the added new adder to calculate the pc value after adding the offset
module new_adder(pc,offset,result_pc);
	input[31:0] pc,offset;//inputs
	output[31:0] result_pc;//outputs
	assign #2 result_pc = pc+offset;//both are added
endmodule



//this is the module to do the sign extension
module sign_extend(offset,result);
	input[7:0] offset;
	output[31:0] result;
	
	assign result= {{24{offset[7]}}, offset};//sign extend is done using contatinating
	
endmodule


//this is the module to multiply by 4
module multiply_4 (inp,result);
	input[31:0] inp;
	output[31:0] result;
	assign result=inp<<2;//it is done by logical shifting by 4
endmodule





