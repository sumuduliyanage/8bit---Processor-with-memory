/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This piece of code contains the alu module which is able to do basic commands add,sub,or,and,loadi,mov,sll,srl,ror,sra . Test bench is also implemented to test the code for different inputs
*/


`timescale 1ns/100ps


//There are three inputs for the alu module - DATA1, DATA2, SELECT
//RESULT is the output of the alu module
//module for alu
module alu(DATA1, DATA2, RESULT, SELECT,ZERO);
	input [7:0]DATA1,DATA2;//two operands
	input [2:0]SELECT;//this is the alu opcode
	output [7:0]RESULT;//the output result
	output wire ZERO;
	
	reg [7:0]RESULT;
	
	reg[7:0] REMAINDER;
	
	
	wire[7:0] FORWARD;
	wire[7:0] ADDRESULT;
	wire[7:0] ANDRESULT;
	wire[7:0] ORRESULT;
	reg[7:0] SLLRESULT;
	reg[7:0] SRLRESULT;
	reg[7:0] SRARESULT;
	reg[7:0] RORRESULT;
	
	/*following part will define whether the result is 0*/
    wire [7:0] OUT;
    
    not (OUT[0],RESULT[0]);//all bits in the result are complemented and have anded
    not (OUT[1],RESULT[1]);
    not (OUT[2],RESULT[2]);
    not (OUT[3],RESULT[3]);
    not (OUT[4],RESULT[4]);
    not (OUT[5],RESULT[5]);
    not (OUT[6],RESULT[6]);
    not (OUT[7],RESULT[7]);
    
    and (ZERO,OUT[0],OUT[1],OUT[2],OUT[3],OUT[4],OUT[5],OUT[6],OUT[7]);//anding all output wires from the not gates


	//loadi , mov , swd , swi ,lwd ,lwi
	
	assign #1 FORWARD =  DATA2;

	
	
	//add , sub
	
    assign #2 ADDRESULT =  DATA1+DATA2;
	
	
	//and 
	
	assign #1 ANDRESULT =  DATA1&DATA2;
	
	
	
	//or
		
	assign #1 ORRESULT =  DATA1|DATA2;
	
	
	
	//logical shift left  - sll
	always @(DATA1,DATA2,SELECT)
	begin
		//for logical shift left-sll
					   #1
					   case(DATA2)//using concatenating we do shifting
							8'd0: SLLRESULT = {DATA1[7:0]};//sll
							8'd1: SLLRESULT = {DATA1[6:0],1'b0};
							8'd2: SLLRESULT = {DATA1[5:0],2'b00};
							8'd3: SLLRESULT = {DATA1[4:0],3'b000};
							8'd4: SLLRESULT = {DATA1[3:0],4'b0000};
							8'd5: SLLRESULT = {DATA1[2:0],5'b00000};
							8'd6: SLLRESULT = {DATA1[1:0],6'b000000};
							8'd7: SLLRESULT = {DATA1[0],7'b0000000};
							default : SLLRESULT = {8'b00000000};
						endcase
		 
	end
	
	
	//for logical shift right-srl
	always @(DATA1,DATA2,SELECT)
	begin
		//for logical shift right-srl
					   #1
					   case(DATA2)//using concatenation
							8'd0: SRLRESULT = {DATA1[7:0]};//srl
							8'd1: SRLRESULT = {1'b0,DATA1[7:1]};
							8'd2: SRLRESULT = {2'b00,DATA1[7:2]};
							8'd3: SRLRESULT = {3'b000,DATA1[7:3]};
							8'd4: SRLRESULT = {4'b0000,DATA1[7:4]};
							8'd5: SRLRESULT = {5'b00000,DATA1[7:5]};
							8'd6: SRLRESULT = {6'b000000,DATA1[7:6]};
							8'd7: SRLRESULT = {7'b0000000,DATA1[7]};
							default : SRLRESULT = {8'b00000000};
						endcase
			
	end
	
	
	//for arithmatic shift right-sra
	always @(DATA1,DATA2,SELECT)
	begin
		//for arithmatic shift right-sra
					   #1
					   case(DATA2)//using concatenation
							8'd0: SRARESULT = {DATA1[7:0]};//sra
							8'd1: SRARESULT = {DATA1[7],DATA1[7:1]};
							8'd2: SRARESULT = {{2{DATA1[7]}},DATA1[7:2]};
							8'd3: SRARESULT = {{3{DATA1[7]}},DATA1[7:3]};
							8'd4: SRARESULT = {{4{DATA1[7]}},DATA1[7:4]};
							8'd5: SRARESULT = {{5{DATA1[7]}},DATA1[7:5]};
							8'd6: SRARESULT = {{6{DATA1[7]}},DATA1[7:6]};
							8'd7: SRARESULT = {{7{DATA1[7]}},DATA1[7]};
							default : SRARESULT = {{8{DATA1[7]}}};
						endcase
	end
	
	
	//for rotate right-ror
	always @(DATA1,DATA2,SELECT)
	begin
		//for rotate right - ror
					   #1
					   REMAINDER = DATA2 % 8'd8;
					   case(REMAINDER)//using concatenation
							8'd0: RORRESULT = {DATA1[7:0]};//ror
							8'd1: RORRESULT = {DATA1[0],DATA1[7:1]};
							8'd2: RORRESULT = {DATA1[1],DATA1[0],DATA1[7:2]};
							8'd3: RORRESULT = {DATA1[2],DATA1[1],DATA1[0],DATA1[7:3]};
							8'd4: RORRESULT = {DATA1[3],DATA1[2],DATA1[1],DATA1[0],DATA1[7:4]};
							8'd5: RORRESULT = {DATA1[4],DATA1[3],DATA1[2],DATA1[1],DATA1[0],DATA1[7:5]};
							8'd6: RORRESULT = {DATA1[5],DATA1[4],DATA1[3],DATA1[2],DATA1[1],DATA1[0],DATA1[7:6]};
							8'd7: RORRESULT = {DATA1[6],DATA1[5],DATA1[4],DATA1[3],DATA1[2],DATA1[1],DATA1[0],DATA1[7]};
						endcase	
	end
	
		
	
	always @(*)
	begin
		case(SELECT)
			3'b000 : RESULT =  FORWARD;//loadi,mov instructions with 1 unit of time delay
			3'b001 : RESULT =  ADDRESULT;//add and sub instructions with 2 time unit delay
			3'b010 : RESULT =  ANDRESULT;//and - 1 time unit delay
			3'b011 : RESULT =  ORRESULT;//or - 1 time unit delay
			3'b100 : RESULT =  SLLRESULT;//logical shift left-sll
			3'b101 : RESULT =  SRLRESULT;//Logical shift right
			3'b110 : RESULT =  SRARESULT;//arithmatic right shift
			3'b111 : RESULT =  RORRESULT;//rotate right
			default : RESULT = 8'bxxxxxxxx;//for invalid aluop signals
		endcase			
	end
	
	
	
	
endmodule










