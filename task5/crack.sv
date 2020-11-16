module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             input logic [23:0] low_key, input logic [23:0] high_key);

    // For Task 5, you may modify the crack port list above,
    // but ONLY by adding new ports. All predefined ports must be identical.

    // your code here
    logic [7:0] pt_addr, pt_rddata, pt_wrdata;
	logic pt_wren, wren_arc4;
	 
	logic [23:0] s_key;
	//logic [23:0] max_key = 24'b1111_1111_1111_1111_1111_1111;
	logic increment_key;
	logic en_arc4, rdy_arc4, rdy_found;
	 
	logic reset;
	logic byte_valid;
	logic [1:0] key_found;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));
    
	arc4 a4(.clk, .rst_n(reset), .en(en_arc4), .rdy(rdy_arc4), .key(s_key), .ct_addr, .ct_rddata,
                .pt_addr, .pt_rddata, .pt_wrdata, .pt_wren(wren_arc4));

    crack_ctrl crack_ctrl_ins(.clk, .rst_n, .en, .rdy_arc4, .byte_valid, .s_key, .max_key(high_key),
								.reset, .en_arc4, .increment_key, .rdy, .key_found);
	 
	 always_comb begin
		byte_valid = (pt_wrdata >= 8'h20 & pt_wrdata <= 8'h7E) | (pt_wrdata === 8'bz);
	 end
	 
	 assign pt_wren = byte_valid ? wren_arc4 : 0;
	 
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) 
			s_key <= low_key;
		else if(increment_key) 
			s_key <= s_key + 24'b10;
		else 
			s_key <= s_key;
	 end
	
	always_ff @(posedge clk) begin
		if(key_found == 2'b01) begin
			key <= s_key;
			key_valid <= 1;
		end else if(key_found == 2'b10) begin
			key <= key;
			key_valid <= 0;
		end
	end

endmodule: crack

module crack_ctrl(input logic clk, input logic rst_n, input logic en, input logic rdy_arc4, 
						input logic byte_valid, input logic [23:0] s_key, input logic [23:0] max_key, 
						output logic reset, output logic en_arc4, output logic increment_key, 
						output logic rdy, output logic [1:0] key_found);
	
	parameter Start = 4'b0000;
	parameter Wait = 4'b0001;
	parameter Reset_ARC4 = 4'b0010;
	parameter Start_ARC4 = 4'b0011;
	parameter Wait_ARC4 = 4'b0100;
	parameter Inc_skey = 4'b0101;
	parameter Finish = 4'b0110;
	parameter No_key = 4'b0111;
	parameter Wait_Start = 4'b1000;
	
	logic [3:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start:		next_state = Wait;
			Wait: 		if(en) next_state = Reset_ARC4;
						else next_state = Wait;
			Reset_ARC4:	next_state = Wait_Start;
			Wait_Start:	next_state = Start_ARC4;
			Start_ARC4: next_state = Wait_ARC4;
			Wait_ARC4: 	if(rdy_arc4) next_state = Finish;
						else if(byte_valid == 0) next_state = Inc_skey;
						else next_state = Wait_ARC4;
			Inc_skey: 	if(s_key == max_key) next_state = No_key;
						else next_state = Reset_ARC4;
			Finish: 	next_state = Wait;
			No_key: 	next_state = Wait;
			default: 	next_state = 4'bxxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 		begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b00; rdy = 0; end
			Wait: 		begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b00; rdy = 1; end
			Reset_ARC4:	begin increment_key = 0; reset = 0; en_arc4 = 0; key_found = 2'b00; rdy = 0; end
			Wait_Start: begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b00; rdy = 0; end
			Start_ARC4: begin increment_key = 0; reset = 1; en_arc4 = 1; key_found = 2'b00; rdy = 0; end
			Wait_ARC4: 	begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b00; rdy = 0; end
			Inc_skey: 	begin increment_key = 1; reset = 1; en_arc4 = 0; key_found = 2'b00; rdy = 0; end
			Finish: 		begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b01; rdy = 1; end
			No_key: 		begin increment_key = 0; reset = 1; en_arc4 = 0; key_found = 2'b10; rdy = 1; end
			default: 	begin increment_key = 1'bx; reset = 1'bx; en_arc4 = 1'bx; key_found = 2'bxx; rdy = 1'bx; end
		endcase
	end
endmodule