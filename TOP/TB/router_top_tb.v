/*

module router_top_tb;
	reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
	reg [7:0]data_in;
	wire valid_out_0,valid_out_1,valid_out_2,err,busy;
	wire [7:0]data_out_0,data_out_1,data_out_2;
	
	always #5 clock = ~clock;
	
	router_top top(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,
	pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,err,busy);
	
	task initialize;
	begin
		{clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid} = 6'd0;
		data_in = 8'd0;
	end 
	endtask
	
	task reset;
	begin
	//	@(negedge clock) resetn=0;
		@(negedge clock) resetn=1;
	end
	endtask
	
	task data_generate;
		reg [1:0]add;
		reg [5:0]payload;
		reg [7:0]header,parity_in;
		integer i;
		
		begin
			add = 2'b01;
			payload = 5'd5;
			header = {payload,add};
			parity_in = 8'b0;
			
				@(negedge clock)
				begin
					pkt_valid = 1'b1;
					data_in = header;
					
					parity_in = parity_in ^ data_in;
				end
				
				@(negedge clock)begin 
					
				end
				
				@(negedge clock)begin 
				end
				
				
				for(i=0;i<payload;i=i+1)
				begin
					
					@(negedge clock)
					begin
						
						data_in = {$random}%256;
						parity_in = parity_in ^ data_in;
					end
				end
				
				
				
				@(negedge clock)
				begin
					pkt_valid = 1'b0;
					data_in = parity_in;
				end	
@(negedge clock)begin 
				end@(negedge clock)begin 
				end
		end
	endtask
		
	task read;
	begin
		if(valid_out_0) read_enb_0 = 1;
		else if(valid_out_1) read_enb_1 =1;
		else if(valid_out_2) read_enb_2 = 1;
		else {read_enb_0,read_enb_1,read_enb_2} = 0;
	end
	endtask
	
	
	initial begin
		initialize;
		reset;
		
			data_generate;
			read;
		
	end
	
endmodule

*/


module router_top_tb;
       reg clock,resetn,read_enb_0,read_enb_1,read_enb_2;
	   reg [7:0] data_in;
	   reg  pkt_valid;
	   wire [7:0] data_out_0,data_out_1,data_out_2;
	   wire valid_out_0,valid_out_1,valid_out_2;
	   wire error,busy;
	   integer i;
	   
	   router_top dut (
	                   clock,
					   resetn,
					   read_enb_0,
					   read_enb_1,
					   read_enb_2,
					   data_in,
					   pkt_valid,
					   data_out_0,
					   data_out_1,
					   data_out_2,
					   valid_out_0,
					   valid_out_1,
					   valid_out_2,
					   error,
					   busy
					   );
	
	always #5 clock = !clock;
		  
		task initialize;
		  begin 
		     { resetn,read_enb_0,read_enb_1, read_enb_2,pkt_valid,clock} = 6'd0;
			 data_in = 8'd0;
			 
			end 
			
		endtask 
		
		
		task reset;
		  begin 
		     @(negedge clock)
			   resetn = 1'b1;
			end 
		endtask
		
		
				
		
		task packet_1;
		     reg [7:0] payload,parity,header;
			 reg [5:0] payload_len;
			 reg [1:0] addr;
			 
			 begin 
			      @(negedge clock)
				      wait(~busy)
				     payload_len = 6'd14;
					 addr = 2'b10;
					 parity= 8'd0;
					 pkt_valid = 1'b1;
					 header = {payload_len,addr};
					 data_in = header;
					 parity = parity ^ header;
			
					 
			      @(negedge clock)
				     wait(~busy)
					 
				      for(i=0;i<payload_len;i=i+1)
					    begin 
						      @(negedge clock)
							     wait(~busy)
								  payload = {$random} %150;
								  data_in = payload;
								  parity = parity ^ data_in;
								  
						end 
						
				   @(negedge clock)
				      wait(~busy)
				          pkt_valid = 1'b0;
						  data_in = parity;
						  
				end 
				endtask
				
				
				
   initial   
      begin 
	       initialize;
			reset;
			packet_1;
			fork
			@(negedge clock);
			   wait(~busy) begin
			    read_enb_2 = 1'b1; 
				end
			 //  wait(~valid_out_2)
			   //  read_enb_2 = 1'b0;
			join
			//#500; $finish;
     end 
				
	endmodule
