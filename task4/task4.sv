module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here

    logic [23:0] key;
	logic [7:0] ct_addr, ct_rddata;
	logic wren, en_crack, rdy_crack, key_valid;
	logic [4:0] char0, char1, char2, char3, char4, char5;
	logic done_crack;
	logic [7:0] ct_wrdata;
	 
	task4_ctrl task4_ctrl_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .rdy_crack, .en_crack, .done_crack);
	 
    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .data(ct_wrdata), .wren(1'b0), .q(ct_rddata));
    
	crack c(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_crack), .rdy(rdy_crack), .key, .key_valid, .ct_addr, .ct_rddata);

    hexdisplay HEX5_task4(.char(char5), .HEX(HEX5));
	hexdisplay HEX4_task4(.char(char4), .HEX(HEX4));
	hexdisplay HEX3_task4(.char(char3), .HEX(HEX3));
	hexdisplay HEX2_task4(.char(char2), .HEX(HEX2));
	hexdisplay HEX1_task4(.char(char1), .HEX(HEX1));
	hexdisplay HEX0_task4(.char(char0), .HEX(HEX0));

    
	always_ff @(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			char5 <= 5'b11111;
			char4 <= 5'b11111;
			char3 <= 5'b11111;
			char2 <= 5'b11111;
			char1 <= 5'b11111;
			char0 <= 5'b11111;
		end else if(done_crack & key_valid == 1) begin
			char5 <= {1'b0, key[23:20]};
			char4 <= {1'b0, key[19:16]};
			char3 <= {1'b0, key[15:12]};
			char2 <= {1'b0, key[11:8]};
			char1 <= {1'b0, key[7:4]};
			char0 <= {1'b0, key[3:0]};
		end else if(done_crack & key_valid == 0) begin
			char5 <= 5'b10000;
			char4 <= 5'b10000;
			char3 <= 5'b10000;
			char2 <= 5'b10000;
			char1 <= 5'b10000;
			char0 <= 5'b10000;
		end else begin
			char5 <= char5;
			char4 <= char4;
			char3 <= char3;
			char2 <= char2;
			char1 <= char1;
			char0 <= char0;
		end
	end

endmodule: task4

module task4_ctrl(input logic clk, input logic rst_n, input logic rdy_crack, 
						output logic en_crack, output logic done_crack);
	
	parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Start_crack = 3'b010;
	parameter Wait_crack = 3'b011;
	parameter Finish = 3'b100;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 			next_state = Wait;				
			Wait: 			if(rdy_crack) next_state = Start_crack;
							else next_state = Wait;
			Start_crack: 	next_state = Wait_crack;
			Wait_crack: 	if(rdy_crack) next_state = Finish;
							else next_state = Wait_crack;
			Finish: 		next_state = Finish;
			default: 		next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 			begin en_crack = 0; done_crack = 0; end
			Wait: 			begin en_crack = 0; done_crack = 0; end
			Start_crack: 	begin en_crack = 1; done_crack = 0; end
			Wait_crack: 	begin en_crack = 0; done_crack = 0; end
			Finish: 		begin en_crack = 0; done_crack = 1; end
			default: 		begin en_crack = 1'bx; done_crack = 1'bx; end
		endcase
	end
	
endmodule
