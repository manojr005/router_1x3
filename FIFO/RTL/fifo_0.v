/*************************************************************************
	The task is to design an FIFO for router the spec are
	
	1. 16*9 memory
	2. rst is active low at posedge clk -> full =0; empty =1; dout = 0;
	3. internal rst from synchronizer -> dout = Z
	4. lfd from FSM	tell that the data is header or remaining
	
	write 
	
	1. din at w-en =1 && ~full
	
	read 
	
	1. dout at r-en =1 && ~empty
	2. counter based on header to read the written data
	3. decrementing couter if count = 0 it only change when lfd =1;
	4. dout = z at safe rst =1 || count = 0;
**************************************************************************/

module fifo_0(clk,rst,w_en,soft_rst,r_en,din,lfd_state,empty,dout,full);
	input clk,rst,w_en,soft_rst,r_en,lfd_state;
	input [7:0]din;
	output empty,full;
	output  reg [7:0]dout;
	
	reg [8:0]mem[15:0];
	reg [7:0]count;
	reg [4:0]w_p,r_p;
  	integer i;
	
	always@(posedge clk)
	begin
		if(!rst)
		begin
			dout <= 8'h00;
			{w_p,r_p} <= 8'h00;
			for(i=0;i<16;i=i+1)
			begin
				mem[i] <= 8'h00;
			end
		end
		/*
		based on the soft rest from the synchronizer the dout is high impedance
		*/
		
		else if(soft_rst)
		begin
			dout <= 8'dz;
		end
		
		// write condition based on the w_en and the fifo full checking 
		else 
		begin
			if(w_en && !full)
			begin
				mem[w_p] <= {lfd_state,din};
				w_p <= w_p + 1;
				/*if(lfd_state)  // detecting the payload size by checking the lfd state
				begin
					//the 8th location is lfd so from 7 to 2 checking the payload size + 1 for the parity bit
					count <= din[7:2] + 2; 
					
				end*/
			end
			
			if(r_en && !empty)
			begin
				
				if(count == 0)
				begin
					dout<=8'dz;
				end
				else if(count >0)
				begin
					
					dout <= mem[r_p];
					/*if(dout[8]==1)
					begin
						count = dout[7:2]+1; 
					end*/
					r_p <= r_p + 1;
					//count <=count -1;
				
				end
				
			end
			
		end
		
		
	end
	always@(posedge clk)
	begin
		if(!rst)
		begin
			count<=0;
		end
		else if(soft_rst)
		begin
			count<=0;
		end
		else if(mem[r_p[3:0]][8] == 1)
		begin 
			count <= mem[r_p[3:0]][7:2] +1;
		end
		else if(r_en && !empty && count > 0 )
		begin
			count<= count-1;
		end
		else count <=count;
	end
	
	assign empty =  (w_p == r_p);
	assign full = ((w_p[4] & ~r_p[4]) && (w_p[3:0] == r_p[3:0]) );

endmodule