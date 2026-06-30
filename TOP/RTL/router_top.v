module router_top(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,err,busy);
	input clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
	input [7:0]data_in;
	output  valid_out_0,valid_out_1,valid_out_2,err,busy;
	output  [7:0]data_out_0,data_out_1,data_out_2;
	
	wire [7:0] data_out;
	wire [2:0]write_enb;
	
	router_fsm fsm (clock,resetn,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,
	fifo_full, low_pkt_valid,empty_0,empty_1,empty_2,detect_add,ld_state,laf_state,full_state,
	write_enb_reg,rst_int_reg,lfd_state);
	
	
	router_register register (clock,resetn,pkt_valid,data_in[7:0],fifo_full,rst_int_reg,detect_add,ld_state,
	laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,data_out);

	router_sync sync (detect_add,write_enb_reg,clock,resetn,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,
	write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2,data_in[1:0]);
	
	router_fifo fifo1 (clock, resetn, write_enb[0], soft_reset_0, read_enb_0, data_out, lfd_state, empty_0, data_out_0, full_0);
	router_fifo fifo2 (clock, resetn, write_enb[1], soft_reset_1, read_enb_1, data_out, lfd_state, empty_1, data_out_1, full_1);
	router_fifo fifo3 (clock, resetn, write_enb[2], soft_reset_2, read_enb_2, data_out, lfd_state, empty_2, data_out_2, full_2);
	
endmodule;
	
/******************************************************************************************************************
	issues faced during the top block instantiation and verification

	1. fifo_empty_0 and empty_0 name mismatch error 
	2. valid_out_0 and vld_0 name mismatch
	3. all the submodules block were not reset properly the priority were given wrongly
	4. the header is missed due to delay in the write_enb_reg from sync
	5. in sync the write_enb_reg and full condition were written in sequential it needs to be combinational
	6. in the syn for write_enb_reg only if were given not else condition given
	7. in the fsm busy and some signals generated were remain high after the end of the packet, because the default value were not given
	8. ns = ps and default condition for the case were not given
	
*******************************************************************************************************************/