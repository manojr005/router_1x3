module router_register(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);

	input clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
	input [7:0] data_in;
	output reg parity_done,low_pkt_valid,err;
	output reg [7:0]dout;
	
	//internal registers
	reg [7:0]header,data_wait,parity,packet_parity;
	
	
	//parity done block
	
	always@(posedge clock)
	begin
		//parity done condition
		if(!resetn || detect_add) parity_done = 1'b0;
		else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done)) parity_done <= 1'b1;
		else parity_done <= parity_done;
		
		// low_pkt_valid condition
		if(!resetn) low_pkt_valid <= 1'b0;
		else if(ld_state && !pkt_valid) low_pkt_valid <= 1'b1;
		else if(detect_add && rst_int_reg) low_pkt_valid <= 1'b0;
		else low_pkt_valid<= low_pkt_valid;
	end
	
	// dout block
	always@(posedge clock)
	begin
		if(!resetn) dout <= 8'd0;
		else if(lfd_state /*&& pkt_valid*/) dout <= header;
		else if(ld_state && !fifo_full/* check && pkt_valid*/) dout <= data_in;
		else if(laf_state) dout <= data_wait;
		else dout <= dout;
		
	end
	
	// data_wait if full
	always@(posedge clock)
	begin
		if(!resetn) data_wait <= 8'd0;
		else if(ld_state && fifo_full)
			data_wait <= data_in;
		else if(full_state) data_wait <= data_in;
		else data_wait <= data_wait;
	end
	
	
	//header
	always@(posedge clock)
	begin
		if(!resetn) header <= 8'd0;
		else if(detect_add && pkt_valid && (data_in[1:0] != 3)) 
			header <= data_in;
		else header<=header;
	end
	
	// parity calculation block
	
	always@(posedge clock)
	begin
		if(!resetn) parity <= 8'd0;
		else if(detect_add && rst_int_reg) parity <=8'd0;
		else if(lfd_state) parity = parity ^ header;
		else if(pkt_valid && ld_state && !fifo_full) parity = parity ^ data_in;
		else parity <= parity;
	end
	
	//packet_parity storing
	
	always@(posedge clock)
	begin
		if(!resetn) packet_parity <= 8'd0;
		else if(detect_add ) packet_parity <= 8'd0;
		else if((!pkt_valid && ld_state && !fifo_full) || (!parity_done && low_pkt_valid && laf_state) ) packet_parity <= data_in;
		else if( !pkt_valid && rst_int_reg) packet_parity <= 8'd0;
		else packet_parity <= packet_parity;
	end
	
	// error checking
	
	always@(posedge clock)
	begin
		if(!resetn) err<=1'b0;
		else if(parity_done && (parity != packet_parity)) err <= 1'b1;
		else if(detect_add && rst_int_reg) err <= 1'b0;
		else err <= 1'b0;
	end
	
endmodule