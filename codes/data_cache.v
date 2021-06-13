/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of the cache
*/


`timescale 1ns/100ps


module dcache (clock,reset, read,write,address, writedata,readdata,busywait, mem_busywait,mem_readdata, mem_read, mem_write , mem_writedata, mem_address);

	input clock,reset,read,write;
	input [7:0] address,writedata;
	
	output[7:0]	readdata;
	output reg  busywait;
	

	
	//signals regarding the datamemory
	output reg[31:0] mem_writedata;
	output reg[5:0] mem_address;
	output reg mem_read,mem_write;
	
	input[31:0] mem_readdata;
	input mem_busywait;

	
	//implementing the cache memory
    reg validbit[7:0];//1 bit for valid
    reg dirtybit[7:0];// 1 bit for dirty bit
    reg[2:0] tag[7:0];//address tag
    reg[31:0] cache_memory[7:0];//32byte cache memory
    
    
    //from the address
    wire[2:0] addresstag,index;
    wire[1:0] offset;
    
    //for tag comparator
    wire tagresult;
    wire ishit;
    wire[31:0] output_block;
    
    
    wire[31:0] current_data;
    wire[2:0]  current_tag;
    wire current_dirtybit,current_validbit;
    
        
    //cleaning the cache when reset signal is high
    integer i;
	always @(posedge reset)
	begin
		if (reset)
		begin
			//reseting the cache
			for (i=0;i<8; i=i+1)
				cache_memory[i] = 32'd0;
			
			//reseting address tag
			for (i=0;i<8;i++)
				validbit[i] = 1'b0;
			
			//resetting the dirty bit
			for (i=0;i<8;i++)
				dirtybit[i] = 1'b0;
				
			//resetting the addresstag
			for (i=0;i<8;i++)
				tag[i] = 3'b000;
				
			//complete this part to make signals to zero
			busywait = 1'b0;
			state = IDLE;
							
		end
	end
	
	
	//decoding the values in the address
	assign offset = address[1:0];
	assign index = address[4:2];
	assign addresstag = address[7:5];
	
	//comparing tags
	tag_comparator tagcomp(addresstag,current_tag,tagresult);
	
	hit_status hitstat(current_validbit,tagresult,ishit);
		
	//reading data from the cache
	read_cache readcache(current_data,offset,readdata);
	
	//writing into the cache
	write_cache writecache(writedata,offset,current_data,output_block);
		
	
	//making the signals
	always @(*)
	begin
		if ((read == 1)||(write == 1))
			busywait = 1;
		else
			busywait = 0;	
	end
	
	
	
	//exacting the stored values according to the index
	
	assign #1 current_data = cache_memory[index];
	assign #1 current_validbit = validbit[index];
	assign #1 current_dirtybit = dirtybit[index];
	assign #1 current_tag = tag[index];
	


	//writing is done at the positive edge of the clock
	always @(posedge clock)
	begin
		#1 if(write)
		begin
			if (ishit)
			begin
				cache_memory[index] = output_block;
				validbit[index] = 1'b1;
				dirtybit[index] = 1'b1;
			end
		end
	end
		
	
	
	//busy wait signal is handled
	always @(posedge clock)
	begin
		if ((ishit)&&(read||write))
			busywait = 0;
	end
	
	

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */
    

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, CACHE_UPDATE = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirtybit[index] && !ishit)  //when dirty bit is 0
                    next_state = MEM_READ;
                else if ((read || write) && dirtybit[index] && !ishit) //when dirty bit is 1
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)  //when memory is not busy
                    next_state = CACHE_UPDATE;
                else    
                    next_state = MEM_READ;
                    
            MEM_WRITE:
				if (!mem_busywait)//when data memory is not busy
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;
            CACHE_UPDATE:
				if ((ishit) && (read || write))
                    next_state = IDLE;
                else    
                    next_state = CACHE_UPDATE;
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 32'dx;
                //busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {addresstag, index};
                mem_writedata = 32'dx;
                //busywait = 1;
            end
            
            MEM_WRITE: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {current_tag, index};
                mem_writedata = cache_memory[index];
                //busywait = 1;
            end
            
            CACHE_UPDATE:
            begin
				mem_read = 0;
                mem_write = 0;
                #1 cache_memory[index] = mem_readdata;
                tag[index] = addresstag;
				validbit[index] = 1'b1;
				dirtybit[index] = 1'b0;
				//busywait = 1;
			end            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

endmodule



//tag comaparison
module tag_comparator(addresstag,tag,result);
	input[2:0] addresstag;
	input[2:0] tag;
	output wire result;
	
	wire w1,w2,w3;
	
	xor x1 (w1,addresstag[0],tag[0]);
	xor x2 (w2,addresstag[1],tag[1]);
	xor x3 (w3,addresstag[2],tag[2]);
	
	nor #0.9 n1 (result,w1,w2,w3);//adding delay to tag comparison
endmodule


//hit status
module hit_status (validbit,is_tag,ishit);
	input validbit,is_tag;
	output ishit;
	
	and a1(ishit,validbit,is_tag);
endmodule


//read_data from the cache
module read_cache(data_block,offset,outdata);
	input[31:0] data_block;
	input[1:0] offset;
	output[7:0] outdata;
	reg[7:0] outdata;
	
	always @(data_block or offset)
	begin
		#1 if (offset == 2'b00)
		    outdata = data_block[7:0];
		else if (offset == 2'b01)
			outdata = data_block[15:8];
		else if (offset == 2'b10)
			outdata = data_block[23:16];
		else if (offset == 2'b11)
			outdata = data_block[31:24];
	end
endmodule


//write into the cache
module write_cache (data,offset,input_block,output_block);
	input [7:0] data;
	input[1:0] offset;
	input[31:0] input_block;
	
	output[31:0] output_block;
	reg[31:0] output_block;
	
	always @(data or offset or input_block)
	begin
		if (offset == 2'b00)
		     output_block = {input_block[31:8],data};
		else if (offset == 2'b01)
			 output_block = {input_block[31:16],data,input_block[7:0]};
		else if (offset == 2'b10)
			output_block = {input_block[31:24],data,input_block[15:0]};
		else if (offset == 2'b11)
			output_block = {data,input_block[23:0]};
	end
	
endmodule
