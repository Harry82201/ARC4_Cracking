module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here
    logic en_crack_1, en_crack_2;
	logic rdy_crack_1, rdy_crack_2;
	logic [23:0] key_1, key_2;
	logic key_valid_1, key_valid_2;
	logic [23:0] low_key_1 = 24'b0000_0000_0000_0000;
	logic [23:0] low_key_2 = 24'b0000_0000_0000_0001;
	logic [23:0] high_key_1 = 24'b1111_1111_1111_1110;
	logic [23:0] high_key_2 = 24'b1111_1111_1111_1111;

	logic [7:0] ct_addr_1, ct_addr_2;
	 
	logic [7:0] pt_addr, pt_wrdata, pt_rddata;
	logic pt_wren;
    
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));

	doublecrack_ctrl dbcrack_ctrl_ins(.clk, .rst_n, .en, .rdy_crack_1, .rdy_crack_2, .en_crack_1, .en_crack_2, .rdy);

    // for this task only, you may ADD ports to crack
    crack c1(.clk, .rst_n, .en(en_crack_1), .rdy(rdy_crack_1), .key(key_1), .key_valid(key_valid_1), 
                .ct_addr(ct_addr_1), .ct_rddata, .low_key(low_key_1), .high_key(high_key_1));
    crack c2(.clk, .rst_n, .en(en_crack_2), .rdy(rdy_crack_2), .key(key_2), .key_valid(key_valid_2), 
                .ct_addr(ct_addr_2), .ct_rddata, .low_key(low_key_2), .high_key(high_key_2));
    
    // your code here
    always_ff @(posedge clk) begin
		if(key_valid_1) key <= key_1;
		else if(key_valid_2) key <= key_2;
	end
	 
	always_ff @(posedge clk or negedge rst_n) begin
		if (rst_n == 0) key_valid <= 0;
		else if(key_valid_1 | key_valid_2) key_valid <= 1;
		else key_valid <= 0;
	end

	always_ff @(ct_addr_1 or ct_addr_2) begin
		if(ct_addr_1 == 8'b0) ct_addr <= ct_addr_1;
		else if(ct_addr_1 > ct_addr_2) ct_addr <= ct_addr_1;
		else ct_addr <= ct_addr_2;
	end

	//ct_addr = key_valid_1 ? ct_addr_1 : (key_valid_2 ? ct_addr_2 : )

endmodule: doublecrack

module doublecrack_ctrl(input logic clk, input logic rst_n, input logic en, input logic rdy_crack_1,
								input logic rdy_crack_2, output logic en_crack_1, output logic en_crack_2, 
								output logic rdy);
	
	parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Start_crack_1 = 3'b010;
	parameter Wait_crack = 3'b011;
	parameter Finish = 3'b100;
	parameter Start_crack_2 = 3'b101;
	
	logic [2:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start:			next_state = Wait;
			Wait: 			if(en & rdy_crack_1 & rdy_crack_2) next_state = Start_crack_1;
							else next_state = Wait;
			Start_crack_1:	next_state = Start_crack_2;
			Start_crack_2:	next_state = Wait_crack;
			Wait_crack: 	if(rdy_crack_1 | rdy_crack_2) next_state = Finish;
							else next_state = Wait_crack;
			Finish: 		next_state = Wait;
			//No_key: 		next_state = Wait;
			default: 		next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start:			begin en_crack_1 = 0; en_crack_2 = 0; rdy = 0; end
			Wait: 			begin en_crack_1 = 0; en_crack_2 = 0; rdy = 1; end
			Start_crack_1:	begin en_crack_1 = 1; en_crack_2 = 0; rdy = 0; end
			Start_crack_2:	begin en_crack_1 = 0; en_crack_2 = 1; rdy = 0; end
			Wait_crack: 	begin en_crack_1 = 0; en_crack_2 = 0; rdy = 0; end
			Finish: 		begin en_crack_1 = 0; en_crack_2 = 0; rdy = 1; end
			//No_key: 		begin en_crack_1 = 0; en_crack_2 = 0; end
			default: 		begin en_crack_1 = 1'bx; en_crack_2 = 1'bx; rdy = 1'bx; end
		endcase
	end
	
endmodule
