# 8bit-Processor-with-memory

## INTRODUCTION
8 bit processor is implemented in this project using Verilog HDL. Memory is also implemeted and caching techiniques are also used both for data memory and instruction memory. 

## CPU with Data Memory
![image](https://github.com/sumuduliyanage/8bit-Processor-with-memory/blob/main/docs/img1.PNG)

## CPU with Data Cache and Data Memory
![image](https://github.com/sumuduliyanage/8bit-Processor-with-memory/blob/main/docs/img2.PNG)

## Compilation & Running
### 1.Compile

  iverilog -o test.vvp cpu_testbench.v

### 2.Run

  vvp test.vvp

### 3.Open with gtkwave tool

  gtkwave cpu_wavedata.vcd

