/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of twos complement hardware
*/

`timescale 1ns/100ps

//module for two's complement
module twos_complement(data,result);
	input[7:0] data;//input data
	output[7:0] result;//output data
	
	assign #1 result = ~data+1'b1;//the input is inverted and 1 is added to convert into twos complement
endmodule
