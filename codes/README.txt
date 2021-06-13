1.Compile

iverilog -o test.vvp cpu_testbench.v


2.Run

vvp test.vvp


3.Open with gtkwave tool

  gtkwave cpu_wavedata.vcd


I have include the E16200_Assembler.c file as well. (Because my opcodes are different from the Assembler that is given for us)
