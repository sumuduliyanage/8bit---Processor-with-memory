/*
Author: E/16/200
Name: Lakmali B.L.S
Lab 6
Part 3
This is the implemetation of the cache for instructions
*/



module icache(clock , reset, read, pc, instruction , busywait , imem_read , imem_address , imem_readdata , imem_busywait);

	input clock,reset,read;
	input[31:0] pc;
	
	output[31:0] instruction;
	output reg busywait;
	
	
	input imem_busywait;
	input[127:0] imem_readdata;
	
	output reg imem_read;
	output reg[5:0] imem_address;
	
	wire[1:0] offset;
	wire[2:0] index,addresstag;
	
	wire[127:0] current_instructionblock;
	wire current_validbit;
	wire [2:0] current_tag;
	
	//tag comparator
	wire tagresult;
    wire ishit;
    wire[31:0] outinstruction;
    	
	
	//implementing the instruction cache memory
    reg validbit[7:0];//1 bit for valid
    reg[2:0] tag[7:0];//address tag
    reg[127:0] cache_memory[7:0];//128byte cache memory
    
    
    integer i;
	always @(posedge reset)
	begin
		if (reset)
		begin
			//reseting the cache
			for (i=0;i<8; i=i+1)
				cache_memory[i] = 128'd0;
			
			//reseting address tag
			for (i=0;i<8;i++)
				validbit[i] = 1'b0;
							
			//resetting the addresstag
			for (i=0;i<8;i++)
				tag[i] = 3'b000;
				
			//complete this part to make signals to zero
			busywait = 1'b0;
			state = IDLE;
							
		end
	end
	
	
	
	//extracting tag,index , and offset from the pc
	assign offset = pc[3:2];
	assign index = pc[6:4];
	assign addresstag = pc[9:7];
	
	//extracting from cache memory accoring to the index
	assign #1 current_instructionblock = cache_memory[index];
	assign #1 current_validbit = validbit[index];
	assign #1 current_tag = tag[index];
	
	//comparing tags
	instag_comparator tagcomp(addresstag,current_tag,tagresult);
	
	inshit_status hitstat(current_validbit,tagresult,ishit);
	
	//reading data from the cache
	insread_cache readcache(current_instructionblock,offset,instruction);
	
	
	//making the signals
	always @(*)
	begin
		if (read == 1)
			busywait = 1;
		else
			busywait = 0;	
	end
	
	
	//busy wait signal is handled
	always @(posedge clock)
	begin
		if ( ishit && read )
			busywait = 0;
	end
	
	
	//FSM to handle read misses
	parameter IDLE = 3'b000, MEM_READ = 3'b001, CACHE_UPDATE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (read && !ishit) //if it is not a hit 
                    next_state = MEM_READ;
                else
                    next_state = IDLE; 
            MEM_READ:
                if (!imem_busywait)//when instruction memory is not busy
                    next_state = CACHE_UPDATE;
                else    
                    next_state = MEM_READ;       
            CACHE_UPDATE:
				if (ishit && read)//when there is a hit
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
                imem_read = 0;
                imem_address = 6'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                imem_read = 1;
                imem_address = {addresstag, index};
                busywait = 1;
            end           
            CACHE_UPDATE:
            begin
				imem_read = 0;
				busywait = 1;
				imem_address = 6'dx;
                #1 cache_memory[index] = imem_readdata;
                tag[index] = addresstag;
				validbit[index] = 1'b1;
				
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
module instag_comparator(addresstag,tag,result);
	input[2:0] addresstag;
	input[2:0] tag;
	output wire result;
	
	wire w1,w2,w3;
	
	xor x1 (w1,addresstag[0],tag[0]);
	xor x2 (w2,addresstag[1],tag[1]);
	xor x3 (w3,addresstag[2],tag[2]);
	
	nor #1 n1 (result,w1,w2,w3);//adding delay to tag comparison
endmodule


//hit status
module inshit_status (validbit,is_tag,ishit);
	input validbit,is_tag;
	output ishit;
	
	and a1(ishit,validbit,is_tag);
endmodule


//read_data from the cache
module insread_cache(instruction_block,offset,outinstruction);
	input[127:0] instruction_block;
	input[1:0] offset;
	
	output[31:0] outinstruction;
	reg[31:0] outinstruction;
	
	always @(instruction_block or offset)
	begin
		#1 if (offset == 2'b00)
		    outinstruction = instruction_block[31:0];
		else if (offset == 2'b01)
			outinstruction = instruction_block[63:32];
		else if (offset == 2'b10)
			outinstruction = instruction_block[95:64];
		else if (offset == 2'b11)
			outinstruction = instruction_block[127:96];
	end
	
endmodule
