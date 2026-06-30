module router_register_tb;

	reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
	reg [7:0] data_in;
	wire parity_done,low_pkt_valid,err;
	wire [7:0]dout;
	
	router_register r1(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);
	
	always #5 clock = ~clock;
	
	task initilize;
	begin
		{clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state} = 9'd0;
		data_in = 8'd0;
		#10;
	end 
	endtask
	
	task reset;
	begin
		@(negedge clock);
		resetn = 1'b0;
		@(negedge clock);
		resetn = 1'b1;		
	end
	endtask
	
	task pack_generate_1;
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
				detect_add = 1'b1;
				pkt_valid = 1'b1;
				data_in = header;
				parity_in = parity_in ^ data_in;
			end
			
			
			@(negedge clock) 
			begin
				lfd_state = 1'b1;
				detect_add = 1'b0;
			end
	
			
			for(i=0;i<payload;i=i+1)
			begin
				@(negedge clock)
				begin
				lfd_state = 1'b0;
					ld_state = 1'b1;
					data_in = {$random}%256;
					parity_in = parity_in ^ data_in;
				end
			end
			
			@(negedge clock)
			begin
				pkt_valid = 1'b0;
				fifo_full = 1'b0;
				data_in = parity_in;
			end	
		end
	endtask
	
	
	task pack_generate_2;
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
				detect_add = 1'b1;
				pkt_valid = 1'b1;
				data_in = header;
				//parity_in = parity_in ^ data_in;
			end
			
			
			@(negedge clock) 
			begin
				lfd_state = 1'b1;
				detect_add = 1'b0;
			end
	
			
			for(i=0;i<payload;i=i+1)
			begin
				@(negedge clock)
				begin
				lfd_state = 1'b0;
					ld_state = 1'b1;
					data_in = {$random}%256;
					parity_in = parity_in ^ data_in;
				end
			end
			
			@(negedge clock)
			begin
				pkt_valid = 1'b0;
				fifo_full = 1'b0;
				data_in = parity_in;
			end	
		end
	endtask
	
	initial
	begin
		initilize;
		reset;
		pack_generate_1;
		pack_generate_2;
	end
	
endmodule

