module router_fsm (clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,
fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,
write_enb_reg,rst_int_reg,lfd_state);

input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,
fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;

output reg detect_add,ld_state,laf_state,full_state,
write_enb_reg,rst_int_reg,lfd_state,busy;

parameter decode_address = 3'd0,
load_first_data = 3'd1, 
load_data = 3'd2,
load_parity = 3'd3,
fifo_full_state = 3'd4,
load_after_full = 3'd5,
check_parity_error = 3'd6,
wait_till_empty = 3'd7;

reg [2:0]ns,ps;
reg [1:0]addr;
wire load,empty,full,reload,reparity,parity;

// check the working of the fsm again and the logic read the spec carefully and change the logic

always@(posedge clock)
begin
	if((!resetn )|| (soft_reset_0 || soft_reset_1 || soft_reset_2))
	begin
		ps <= decode_address;
	//	addr <= 0;
	end
	else 
		ps <= ns;
end


always@(*)
begin
	{detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy,addr} = 10'd0;
	ns = ps;
	case(ps)
		decode_address:  begin
							detect_add = 1'b1;
							if(load) ns = load_first_data;
							else if(full) ns = wait_till_empty;
							//else if(!resetn) ns = decode_address;
							else ns = decode_address;	
						end
						
		load_first_data: begin
							lfd_state = 1'b1;
							busy = 1'b1;
							ns = load_data;
						 end
						 
		load_data     	:begin
							ld_state = 1'b1;
							busy = 1'b0;
							write_enb_reg = 1'b1;
							if(parity) ns = load_parity;
							else if (fifo_full) ns = fifo_full_state;
							else ns = load_data;
						end
						
		load_parity 	:begin
							busy = 1'b1;
							write_enb_reg = 1'b1;
							ns = check_parity_error;
						end
		check_parity_error:begin
							rst_int_reg= 1'b1;
							busy = 1'b1;
							if(!fifo_full) ns = decode_address;
							else  ns = fifo_full_state;
							
							end
		fifo_full_state	:begin
							busy = 1'b1;
							write_enb_reg = 1'b0;
							full_state = 1'b1;
							if(!fifo_full) ns = load_after_full;
							else ns = fifo_full_state;
						end
		load_after_full	:begin
							laf_state = 1'b1;
							busy = 1'b1;
							write_enb_reg = 1'b1;
							if(parity_done) ns = decode_address;
							else if(reparity) ns = load_parity;
							else if(reload) ns = load_data;
							else ns = load_after_full;
						end
		wait_till_empty	:begin
							busy = 1'b1;
							write_enb_reg = 1'b0;
							addr = data_in;
							if(empty) ns = load_first_data;
							else ns = wait_till_empty;
						end
		default : ns = decode_address;
	endcase

end

assign load = ((pkt_valid & (detect_add == 0) & fifo_empty_0) | (pkt_valid & (detect_add == 1) & fifo_empty_1) | (pkt_valid & (detect_add == 2) & fifo_empty_2));
assign parity = (!fifo_full && !pkt_valid);
assign reload = (!parity_done && !low_pkt_valid);
assign reparity = (!parity_done && low_pkt_valid);
assign full = (pkt_valid & (detect_add == 0) & !fifo_empty_0 | pkt_valid & (detect_add == 1) & !fifo_empty_1 | pkt_valid & (detect_add == 2) & !fifo_empty_2);
assign empty = ((fifo_empty_0 && (addr == 0))||(fifo_empty_1 && (addr == 1))||(fifo_empty_2 && (addr == 2)));
endmodule
