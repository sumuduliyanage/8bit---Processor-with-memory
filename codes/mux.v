/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of a two to one mux
*/

`timescale 1ns/100ps

//2:1 mux
module mux2_1(SELECT,INPUT1,INPUT2,RESULT);
	input SELECT;//select signal of the mux
	input[7:0] INPUT1,INPUT2;//inputs 
	
	output[7:0] RESULT;
	reg[7:0] RESULT;
	
	always @ (SELECT or INPUT1 or INPUT2)//sesitivity list 
	 //in sequential circuits , posedge clk is the sensitivity list
	 
	 begin 
	 
		if (SELECT == 1'b0)
		begin
			RESULT = INPUT1;//when select is 0 , result is the input 1
		end
		else if (SELECT == 1'b1)
		begin
			RESULT = INPUT2;//when select is 1, result is input 0
		end	
		else
		begin
			RESULT = 8'bxxxxxxxx;//otherwise result is don't care
		end
				
	 end
	
endmodule
