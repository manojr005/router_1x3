/*************************************************************************
	The task is to design an FIFO for router the spec are
	
	1. 16*9 memory
	2. resetn is active low at posedge clock -> full =0; empty =1; data_out = 0;
	3. internal resetn from synchronizer -> data_out = Z
	4. lfd from FSM	tell that the data is header or remaining
	
	write 
	
	1. data_in at w-en =1 && ~full
	
	read 
	
	1. data_out at r-en =1 && ~empty
	2. counter based on header to read the written data
	3. decrementing couter if count = 0 it only change when lfd =1;
	4. data_out = z at safe resetn =1 || count = 0;
**************************************************************************/

module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);
	input clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
	input [7:0]data_in;
	output empty,full;
	output  reg [7:0]data_out;
	
	reg [8:0]mem[15:0];
	reg [7:0]count;
	reg [4:0]w_p,r_p;
  	integer i;
	reg temp;
	
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			data_out <= 8'h00;
			{w_p,r_p} <= 8'h00;
			for(i=0;i<16;i=i+1)
			begin
				mem[i] <= 8'h00;
			end
			//temp <= lfd_state;
		end
		/*
		based on the soft rest from the synchronizer the data_out is high impedance
		*/
		
		else if(soft_reset)
		begin
			data_out <= 8'dz;
		end
		
		// write condition based on the write_enb and the fifo full checking 
		else 
		begin
			if(write_enb && !full)
			begin
				temp <= lfd_state;
				{mem[w_p[3:0]][8],mem[w_p[3:0]][7:0]} <= {temp,data_in};
				w_p <= w_p + 1'b1;
			end
			
			if(count == 1'b0)
				begin 
					data_out <= 8'dz;
				end
			if(read_enb && !empty)
			begin
					data_out <= mem[r_p[3:0]];
					r_p <= r_p + 1'b1;
				end
				//else data_out <= data_out;
			//end
			
		end
	end
	
	
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			count<=0;
		end
		else if(soft_reset)
		begin
			count<=0;
		end
		else if(read_enb && !empty) 
		begin 
			if(mem[r_p[3:0]][8] == 1)
			begin 
				count <= mem[r_p[3:0]][7:2] +1'b1;
			end
			 if(count > 0 )
			begin
				count<= count-1;
			end
		end
		else count <=count;
	end
	
	assign empty =  (w_p == r_p);
	assign full = ((w_p[4] & ~r_p[4]) && (w_p[3:0] == r_p[3:0]) );

endmodule