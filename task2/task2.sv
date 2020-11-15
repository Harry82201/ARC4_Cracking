module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic [23:0] key;
	logic [7:0] address_to_mem, addr_init, addr_ksa;
	logic [7:0] data_to_mem, wrdata_init, wrdata_ksa;
	logic [7:0] data_from_mem;
	logic wren, wren_init, wren_ksa;
	logic en, en_ksa;
	logic rdy_init, rdy_ksa;
	 
	assign key = {{14{1'b0}}, SW[9:0]};
	 
	task2_ctrl task2_ctrl_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .rdy_init, .rdy_ksa, .en_init(en), .en_ksa);

    s_mem s(.address(address_to_mem), .clock(CLOCK_50), .data(data_to_mem), .wren(wren), .q(data_from_mem));

    init init_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .en, .rdy(rdy_init), .addr(addr_init), .wrdata(wrdata_init), .wren(wren_init));
	 
	ksa ksa_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_ksa), .rdy(rdy_ksa), .key, .addr(addr_ksa), .rddata(data_from_mem), .wrdata(wrdata_ksa), .wren(wren_ksa));
					 
	assign address_to_mem = rdy_init ? addr_ksa : addr_init;
	assign data_to_mem = rdy_init ? wrdata_ksa : wrdata_init;
	assign wren = rdy_init ? wren_ksa : wren_init;

endmodule: task2

module task2_ctrl(input logic clk, input logic rst_n, input logic rdy_init, input logic rdy_ksa,
						output logic en_init, output logic en_ksa);
	
	parameter Start = 3'b000;
	parameter Start_init = 3'b001;
	parameter Wait_init = 3'b010;
	parameter Finish_init = 3'b011;
	parameter Start_ksa = 3'b100;
	parameter Wait_ksa = 3'b101;
	parameter Finish = 3'b110;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 			if(rdy_init) next_state = Start_init;
							else next_state = Start;
			Start_init: 	next_state = Wait_init;
			Wait_init: 		if(rdy_init) next_state = Finish_init;
							else next_state = Wait_init;
			Finish_init: 	if(rdy_ksa) next_state = Start_ksa;
							else next_state = Finish_init;
			Start_ksa: 		next_state = Wait_ksa;
			Wait_ksa: 		if(rdy_ksa) next_state = Finish;
							else next_state = Wait_ksa;
			Finish: 		next_state = Finish;
			default: 		next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 			begin en_init = 0; en_ksa = 0; end
			Start_init: 	begin en_init = 1; en_ksa = 0; end
			Wait_init: 		begin en_init = 0; en_ksa = 0; end
			Finish_init:	begin en_init = 0; en_ksa = 0; end
			Start_ksa: 		begin en_init = 0; en_ksa = 1; end
			Wait_ksa: 		begin en_init = 0; en_ksa = 0; end
			Finish: 		begin en_init = 0; en_ksa = 0; end 
			default: 		begin en_init = 1'bx; en_ksa = 1'bx; end
		endcase
	end
	
endmodule