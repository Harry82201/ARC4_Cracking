module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [23:0] key;
	logic en_arc4, rdy_arc4, pt_wren;
	logic [7:0] ct_addr, pt_addr;
	logic [7:0] ct_rddata, pt_rddata;
	logic [7:0] pt_wrdata;
	 
	assign key = {{14{1'b0}}, SW[9:0]};
	 
	task3_ctrl task3_ctrl_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .rdy_arc4, .en_arc4);

    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .data(8'b0), .wren(1'b0), .q(ct_rddata));
    pt_mem pt(.address(pt_addr), .clock(CLOCK_50), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));
    arc4 a4(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_arc4), .rdy(rdy_arc4), .key,
            .ct_addr, .ct_rddata, .pt_addr, .pt_rddata, .pt_wrdata, .pt_wren);

endmodule: task3

module task3_ctrl(input logic clk, input logic rst_n, input logic rdy_arc4, output logic en_arc4);
	
	parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Start_arc4 = 3'b010;
	parameter Wait_arc4 = 3'b011;
	parameter Finish = 3'b100;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 			next_state = Wait;				
			Wait: 			if(rdy_arc4) next_state = Start_arc4;
							else next_state = Wait;
			Start_arc4: 	next_state = Wait_arc4;
			Wait_arc4: 		if(rdy_arc4) next_state = Finish;
							else next_state = Wait_arc4;
			Finish: 		next_state = Finish;
			default: 		next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 			en_arc4 = 0;
			Wait: 			en_arc4 = 0; 
			Start_arc4: 	en_arc4 = 1; 
			Wait_arc4: 		en_arc4 = 0; 
			Finish: 		en_arc4 = 0;  
			default: 		en_arc4 = 1'bx; 
		endcase
	end
	
endmodule