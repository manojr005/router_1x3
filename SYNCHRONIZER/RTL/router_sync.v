module router_sync(detect_add,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,
write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2,data_in);

	input detect_add,write_enb_reg,clock,resetn,read_enb_0;
	input read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2 ;
	input [1:0] data_in;
	output reg vld_out_0,vld_out_1,vld_out_2,fifo_full;
	output reg [2:0]write_enb;
	output soft_reset_0,soft_reset_1,soft_reset_2;

	reg [1:0]temp; 
	
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			{vld_out_0,vld_out_1,vld_out_2} <= 3'd0;
			{/*soft_reset_0,soft_reset_1,soft_reset_2,*/fifo_full} <= 4'd0;
			write_enb = 3'd0;
			
		end
		else
		begin
			// address detection and storing it in a temporary memory to avoid confusion between the address and other data based on detect_add high
			if(detect_add) 
			begin
				temp = data_in;
			//else data_in <= data_in;
			end 
			else temp <= temp;
		end
	
	end
	 // module for soft reset is instantiated here
	
		soft_rst r1 (vld_out_0,read_enb_0,clock,resetn,soft_reset_0);
		soft_rst r2 (vld_out_1,read_enb_1,clock,resetn,soft_reset_1);
		soft_rst r3 (vld_out_2,read_enb_2,clock,resetn,soft_reset_2);

	//combinational circuit for the valid out is done
	
	always@(*)
	begin
		vld_out_0 = ~empty_0;
		vld_out_1 = ~empty_1;
		vld_out_2 = ~empty_2;
	
	if(write_enb_reg)
		begin
			case(temp)
				2'b00: write_enb = 3'b001;
				2'b01: write_enb = 3'b010;
				2'b10: write_enb = 3'b100;
				default: write_enb = 3'b000;
			endcase
		end  
	else write_enb = 3'b000;
				
				//fifo full condition based on the full signal from the fifo
				case(temp)
					2'b00: fifo_full = full_0;
					2'b01: fifo_full = full_1;
					2'b10: fifo_full = full_2;
					default: fifo_full = 1'b0;
				endcase
	end
endmodule

// module written for soft resest based on the valid and read enable from the fifo

module soft_rst (
input vld,r_en,clk,r,
output reg rst
);

	reg [32:0]count;
	always@(posedge clk)
	begin
		if(!r)
		begin
			count<= 1'b0;
			rst <= 1'b0;
		end
		else if(vld)
		begin
			
			if(r_en) 
			begin 
				count <= 1'b0;
				
			end
			else 
			begin
				count <= count+1'b1;
				if(count == 30) 
				begin
					rst <= 1'b1;
					count <= 1'b0;
				end
				else rst <= 1'b0;
			end
		end
		else count <= 1'b0;
	end
endmodule