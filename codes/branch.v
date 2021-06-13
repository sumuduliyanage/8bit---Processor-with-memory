/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of an and gate to check whether we should do the branch
*/

`timescale 1ns/100ps

//branch module
module branch (iszero,branch_select,dobranch);

	input iszero,branch_select;
	output  wire dobranch; 
	
	assign  dobranch = iszero & branch_select;//when alu result is zero, and the instruction is beq , dobrach is going high
	
endmodule
