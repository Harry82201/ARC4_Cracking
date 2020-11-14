module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [7:0] address_to_mem;
	logic [7:0] data_to_mem;
	logic [7:0] data_from_mem;
	logic wren;
	logic en;
	logic rdy;
	
	task1_ctrl task1_ctrl_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .rdy_init(rdy), .en_init(en));

    s_mem s(.address(address_to_mem), .clock(CLOCK_50), .data(data_to_mem), .wren(wren), .q(data_from_mem));

    // your code here
    init init_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .en, .rdy, .addr(address_to_mem), .wrdata(data_to_mem), .wren);

endmodule: task1

module task1_ctrl(input logic clk, input logic rst_n, input logic rdy_init, output logic en_init);
	
	parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Start_init = 3'b010;
	parameter Wait_init = 3'b011;
	parameter Finish = 3'b100;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 			next_state = Wait;				
			Wait: 			if(rdy_init) next_state = Start_init;
							else next_state = Wait;
			Start_init: 	next_state = Wait_init;
			Wait_init: 		if(rdy_init) next_state = Finish;
							else next_state = Wait_init;
			Finish: 		next_state = Finish;
			default: 		next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 			en_init = 0;
			Wait: 			en_init = 0; 
			Start_init: 	en_init = 1; 
			Wait_init: 		en_init = 0; 
			Finish: 		en_init = 0;  
			default: 		en_init = 1'bx; 
		endcase
	end
	
endmodule