/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of an and gate a not gate to clarify whether bne instruction has to be executed
*/

`timescale 1ns/100ps

//bne 
module bne(iszero,bne_select,result);

	input iszero,bne_select;
	output result;
	
	assign result = (~iszero)&(bne_select);//when the alu result is not zero and bne_select signal is high , result signal becomes high
	
endmodule
