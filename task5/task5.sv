module task5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [23:0] key;
	logic [7:0] ct_addr, ct_rddata;
	logic wren, en_doublecrack, rdy_doublecrack, key_valid;
	logic [4:0] char0, char1, char2, char3, char4, char5;
	logic done_doublecrack;
	 
	//assign en_doublecrack = 1;
	 
	task5_ctrl task5_ctrl_ins(.clk(CLOCK_50), .rst_n(KEY[3]), .rdy_doublecrack, .en_doublecrack, .done_doublecrack);

    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .data(8'b0), .wren(1'b0), .q(ct_rddata));
    
	doublecrack dc(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en_doublecrack), .rdy(rdy_doublecrack), .key, .key_valid, .ct_addr, .ct_rddata);

    hexdisplay HEX5_task5(.char(char5), .HEX(HEX5));
	hexdisplay HEX4_task5(.char(char4), .HEX(HEX4));
	hexdisplay HEX3_task5(.char(char3), .HEX(HEX3));
	hexdisplay HEX2_task5(.char(char2), .HEX(HEX2));
	hexdisplay HEX1_task5(.char(char1), .HEX(HEX1));
	hexdisplay HEX0_task5(.char(char0), .HEX(HEX0));

    always_ff @(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			char5 <= 5'b11111;
			char4 <= 5'b11111;
			char3 <= 5'b11111;
			char2 <= 5'b11111;
			char1 <= 5'b11111;
			char0 <= 5'b11111;
		end else if(done_doublecrack & key_valid == 1) begin
			char5 <= {1'b0, key[23:20]};
			char4 <= {1'b0, key[19:16]};
			char3 <= {1'b0, key[15:12]};
			char2 <= {1'b0, key[11:8]};
			char1 <= {1'b0, key[7:4]};
			char0 <= {1'b0, key[3:0]};
		end else if(done_doublecrack & key_valid == 0) begin
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

endmodule: task5

module task5_ctrl(input logic clk, input logic rst_n, input logic rdy_doublecrack, 
						output logic en_doublecrack, output logic done_doublecrack);
	
	parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Start_doublecrack = 3'b010;
	parameter Wait_doublecrack = 3'b011;
	parameter Finish = 3'b100;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 				next_state = Wait;				
			Wait: 				if(rdy_doublecrack) next_state = Start_doublecrack;
								else next_state = Wait;
			Start_doublecrack: 	next_state = Wait_doublecrack;
			Wait_doublecrack: 	if(rdy_doublecrack) next_state = Finish;
								else next_state = Wait_doublecrack;
			Finish: 			next_state = Finish;
			default: 			next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 				begin en_doublecrack = 0; done_doublecrack = 0; end
			Wait: 				begin en_doublecrack = 0; done_doublecrack = 0; end
			Start_doublecrack: 	begin en_doublecrack = 1; done_doublecrack = 0; end
			Wait_doublecrack: 	begin en_doublecrack = 0; done_doublecrack = 0; end
			Finish: 			begin en_doublecrack = 0; done_doublecrack = 1; end
			default: 			begin en_doublecrack = 1'bx; done_doublecrack = 1'bx; end
		endcase
	end
	
endmodule