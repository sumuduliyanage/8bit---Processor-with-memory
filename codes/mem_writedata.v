/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation to find the data to write data in to the data memory
*/

`timescale 1ns/100ps

module mem_writedata(data,result);
	input[7:0] data;
	output wire[7:0] result;
	
	assign result = data;
endmodule
