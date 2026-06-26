module router_sync_tb;
	reg detect_add,write_enb_reg,clock,resetn,read_enb_0;
	reg read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2 ;
	reg [1:0] data_in;
	wire vld_out_0,vld_out_1,vld_out_2,soft_reset0,soft_reset1,soft_reset2,fifo_full;
	wire [2:0]write_enb;

router_sync s1 (detect_add,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,
write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset0,soft_reset1,soft_reset2,full_0,full_1,full_2,data_in);

	always #5 clock = ~clock;
	
	task initialize;
		begin 
			{detect_add, write_enb_reg, clock, resetn, read_enb_0, read_enb_1, read_enb_2, full_0, full_1, full_2} = 0;
			{ empty_0, empty_1, empty_2} = 3'b111;
			data_in = 2'b00;
			repeat(5) 
			@(negedge clock)resetn = 0;
			@(negedge clock)resetn = 1;
			#20;
		end
	endtask
	

	
// use this task whenever you need to give an new address to choose the fifo
	task add_capture(input addr, input [1:0]din);
	begin
		@(negedge clock)
			detect_add = addr;
			data_in = din;
		@(negedge clock)
			detect_add = 1'b0;
	end
	endtask
	
//use this task whenever you need to write on the choosen fifo
	task write(input w);
	begin
		@(negedge clock)
			write_enb_reg = w;
	end
	endtask

//use this task whenever you need to check the working of fifo_full for the selected and difference fifo
	task fifo_f(input f1,f2,f3);
	begin
		@(negedge clock)
		begin
			full_0 = f1;
			full_1 = f2;
			full_2 = f3;
		end
	end
	endtask
// use this task to generate the empty condtion from the fifo
	task empty(input e1,e2,e3);
	begin
		@(negedge clock)
		begin
			empty_0 = e1;
			empty_1 = e2;
			empty_2 = e3;
		end
	end
	endtask
//use this task to generate the read condition
	task read(input r1,r2,r3);
	begin
		@(negedge clock)
		begin
			read_enb_0 = r1;
			read_enb_1 = r2;
			read_enb_2 = r3;
		end
	end
	endtask
	
	initial 
	begin
	
	initialize;
	// high detect_add and give address as 1
	add_capture(1'b1,2'b01);
	//#10;
	//give write enable for that address
	write(1'b1);
	//#10;
	// check if the fifo is full 
	fifo_f(1'b1,1'b0,1'b1);
//	#10;
	// check the empty condition for the valid signal
	empty(1'b1,1'b0,1'b1);
//	#10;
	// read the location
	read(1'b0,1'b1,1'b0);
	#10;
	
	// give new address 2 
	add_capture(1'b1,2'b10);
	#10;
	//give valid signal for selected address
	empty(1'b1,1'b1,1'b0);
	#330; // dont read more that 30 cycle 
	
	// give same address 2 
	add_capture(1'b1,2'b10);
	#10;
	//give valid signal for selected address
	empty(1'b1,1'b1,1'b0);
	#10;
	read(1'b0,1'b1,1'b1);
	#100;
	
	// test without detect_add
	add_capture(1'b0,2'b01);
	#10;
	//give write enable for that address
	write(1'b1);
	#10;
	// check if the fifo is full 
	fifo_f(1'b1,1'b0,1'b1);
	#10;
	// check the empty condition for the valid signal
	empty(1'b1,1'b0,1'b1);
	#500;
	// read the location
	read(1'b0,1'b1,1'b0);
	#10;
	
	
	// give thhe 00 address
	add_capture(1'b1,2'b00);
	#10;
	//give write enable for that address
	write(1'b1);
	#10;
	// check if the fifo is full 
	fifo_f(1'b0,1'b0,1'b0);
	#10;
	fifo_f(1'b0,1'b0,1'b1);
	#10;
	// check the empty condition for the valid signal
	empty(1'b0,1'b0,1'b1);
	#500;
	// read the location
	read(1'b1,1'b1,1'b0);
	#10;
	
	end
	
endmodule