module router_fsm_tb;
	reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2;
	reg fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
	reg [1:0]data_in;
	wire detect_add,ld_state,laf_state,full_state;
	wire  write_enb_reg,busy,rst_int_reg,lfd_state;

	router_fsm f1 (clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,
	fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,
	write_enb_reg,rst_int_reg,lfd_state);
	
	always #5 clock = ~clock;
	
	task initilize;
	begin
		{clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2} = 7'd0;
		{fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2} = 5'd0;
	end
	endtask
	
	/*******************************************************************************
	check the FSM for 4 corner case 
	
	1. check for payload lesser than 10
	2. check for payload equal to 14
	3. check payload greater than 14 (payload = 18)
	4. check payload with fifo full due to before payload 18
	*******************************************************************************/
	
	// to move from decode address to lfd after detection of pkt_valid,data_in & fifo_empty_1
	task decode_to_load;
	begin
		@(negedge clock)
		pkt_valid = 1'b1;
		data_in = 1'b1;
		fifo_empty_1 = 1'b1;
		if(detect_add) $display("detection done %b",detect_add);
		else $display("detection failed %b",detect_add);
	end
	endtask
	
	// payload complete and load parity condition
	task parity_load;
	begin
		@(negedge clock)
		pkt_valid = 1'b0;
		fifo_empty_1 = 1'b0;
		@(negedge clock)
		if(busy && write_enb_reg) $display("parity load done %b, %b", busy,write_enb_reg);
		else $display("parity load failed %b, %b", busy,write_enb_reg);
	end 
	endtask
	
	// fifo empty condition
	task empty;
	begin	
		@(negedge clock)
		fifo_full = 1'b0;
	end
	endtask
	
	// fifo full condition
	task full;
	begin	
		@(negedge clock)
		fifo_full = 1'b1;
	end
	endtask
	
	// fifo reload after not full only for payload greater than 14 
	task reload;
	begin
		@(negedge clock)
		parity_done = 1'b0;
		low_pkt_valid = 1'b0;
	end
	endtask
	
	task reload_parity;
	begin
		@(negedge clock)
		parity_done = 1'b0;
		low_pkt_valid = 1'b1;
		#10;
		@(negedge clock)
		if(busy && write_enb_reg) $display("parity load done %b, %b", busy,write_enb_reg);
		else $display("parity load failed %b, %b", busy,write_enb_reg);
	end
	endtask
	
	// fifo is full in the initial condition
	task wait_full;
	begin
		@(negedge clock)
		pkt_valid = 1'b1;
		data_in = 1'b1;
		fifo_empty_1 = 1'b0;
	end
	endtask
	
	//load the header after the empty condition
	task load_header;
	begin
		@(negedge clock)
		fifo_empty_1 = 1'b1;
		f1.addr = 1;
	end 
	endtask
	
	task check_add;
	begin 
		if(detect_add) $display("detection done %b",detect_add);
		else $display("detection failed %b",detect_add);
	end 
	endtask

	task check_parity;
	begin 
		if(rst_int_reg && busy) $display("parity check done %b, %b", busy,rst_int_reg);
		else $display("parity check failed %b, %b", busy,rst_int_reg);
	end 
	endtask

	task check_load;
	begin 
		if(ld_state && !busy && write_enb_reg) $display("payload load done %b, %b , %b",ld_state,busy,write_enb_reg);
		else  $display("payload load failed %b, %b , %b",ld_state,busy,write_enb_reg);
	end 
	endtask

	task check_lfd;
	begin 
		if(lfd_state && busy) $display("header load done %b, %b",lfd_state,busy);
		else $display("header load failed %b, %b",lfd_state,busy);
	end 
	endtask


	task check_wait;
	begin 
		if(busy && !write_enb_reg) $display("wait condition is true %b, %b",busy,write_enb_reg);
		else $display("wait condition is true %b, %b",busy,write_enb_reg);
	end 
	endtask

	task check_laf;
	begin
		if(laf_state && busy && write_enb_reg) $display("LAF true %b, %b, %b",laf_state,busy,write_enb_reg);
		else $display("LAF false %b, %b, %b",laf_state,busy,write_enb_reg);
			
	end
	endtask

	task check_f_full;
	begin
		if(busy && fifo_full && !write_enb_reg) $display("fifo full state true %b, %b, %b",busy,fifo_full,write_enb_reg);
		else $display("fifo full state false %b, %b, %b",busy,fifo_full,write_enb_reg);
	end
	endtask

	
		
	
	
	
	initial begin
		initilize;
		
		@(negedge clock)
		resetn = 0;
		@(negedge clock)
		resetn = 1;

/****************************************************************************
for payload less than 14 (5)
*****************************************************************************/
		$display("				for payload less than 14 (5)			");
		decode_to_load; 
		$display("					DA");
		// one clock for the unconditional transition
		#10;
		$display("					LFD");
		check_lfd; 
		// 5 clock dealy for the payload to load
		#50; 
		$display("					LD");
		check_load;
		parity_load;
		#10;
		$display("					LP");
		check_parity;
		$display("					CPE");
		// one clock for the unconditional transition
		#10;
		empty;
		#10;
		$display("					DA");
		check_add;
		
		#30;
		
		
		
/****************************************************************************
for payload equal to 14
*****************************************************************************/			
		
	
		$display(" 				for payload equal to 14  ");
		$display("   ");
		$display("   ");
	
		@(negedge clock)
		resetn = 0;
		$display("reset");
		@(negedge clock)
		resetn = 1;
		decode_to_load; 
		$display("					DA");
		// one clock for the unconditional transition
		#10;
		// 14 clock dealy for the payload to load
		$display("					LFD");
		check_lfd;
		#140;
		$display("					LD");
		check_load;
		parity_load;
		// one clock for the unconditional transition
		#10;
		$display("					LP");
		check_parity;
		$display("					CPE");
		full;
		// 1 clock for read and free the space
		#10;
		$display("					FFS");
		check_f_full;
		empty;
		#10;
		$display("					LAF");
		check_laf;
		parity_done = 1'b1;
		#10;
		check_add;
		$display("					DA");
		#30;
		
/****************************************************************************
for payload greater than 14 (16)
*****************************************************************************/			
		
		
		
		$display(" 				for payload greater than 14   ");
		$display("   ");
		$display("   ");
		
		@(negedge clock)
		resetn = 0;
		$display("reset");
		@(negedge clock)
		resetn = 1;
		
		decode_to_load;
		$display("					DA");
		// one clock for the unconditional transition
		#10;
		// 14 clock dealy for the payload to load
		$display("					LFD");
		check_lfd;
		#140;
		$display("					LD");
		check_load;
		full;
		// 1 clock for read and free the space
		#10;
		$display("					FFS");
		check_f_full;
		empty;
		#10;
		$display("					LAF");
		check_laf;
		reload;
		//delay one clock to load data
		#10;
		pkt_valid = 1'b0;
		$display("					LP");
		check_load;
		full;
		// 1 clock for read and free the space
		#10;
		$display("					FFS");
		check_f_full;
		empty;
		#10;
		$display("					LAF");
		check_laf;
		reload_parity;
		$display("					CPE");
		// one clock for the unconditional transition	
		empty;
		#10;
		check_add;
		$display("					DA");
		#30;
		
		

		
/*****************************************************************************
   for payload lesser than 14 (5) but with initial fifo full condition
*******************************************************************************/		
		
		$display(" for payload lesser than 14 (5) but with initial fifo full condition  ");
		$display("   ");
		$display("   ");
		
		@(negedge clock)
		resetn = 0;
		@(negedge clock)
		resetn = 1;
		$display("					DA");
		wait_full;
		//wait untill the fifo gets empty
		#40;
		$display("					WTE");
		check_wait;
		load_header;
		#10;
		$display("					LFD");
		check_lfd;
		// 5 clock dealy for the payload to load
		#50;
		$display("					LD");
		check_load;
		parity_load;
		$display("					LP");
		// one clock for the unconditional transition
		#10;
		$display("					CPE");
		check_parity;
		empty;
		//#10
		
		#10;
		check_add;
		$display("					DA");
		#30;
		
	end
	
endmodule

