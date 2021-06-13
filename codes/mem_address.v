/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation to find the memory address
*/

`timescale 1ns/100ps

module mem_address(alu_result,address);
	input[7:0] alu_result;
	output wire[7:0] address;
	
	assign address = alu_result;//alu gives the output -  a memeory address or a result
endmodule
