`define Start 			5'b00000 
`define Wait  			5'b00001
`define Inc_i  		    5'b00010 
`define Get_si		  	5'b00011 						
`define Store_si  	    5'b00100 
`define Cal_j  		    5'b00101	
`define Get_sj			5'b00110 
`define Store_sj  	    5'b00111 
`define Write_i_to_j    5'b01000 
`define Set_addr_i  	5'b01001	
`define Write_j_to_i	5'b01010	
`define Sum_si_sj	 	5'b01011 
`define Get_padk		5'b01100
`define Store_padk	    5'b01101 
`define Get_CT			5'b01110	
`define Pad_xor_CT	    5'b01111	
`define Store_PT		5'b10000 
`define Inc_k			5'b10001 
`define Check_k 		5'b10010
`define Finish			5'b10011
`define Get_msg_len	    5'b10100
`define Wait_len		5'b10101
`define Store_len		5'b10110

module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
    logic [4:0] state, next_state;
	
	logic [7:0] i_val, j_val, k_val, sum_val;
	logic [7:0] temp_i, temp_j, temp_pad, temp_ct, temp_pt;
	
	logic [1:0] addr_sel;
	
	logic data_out_sel;
	
	logic en_i, en_j, en_pad, en_ct, en_pt;
	logic en_cal_j, en_sum;
	logic increment_i, increment_k;
	
	logic en_len;
	logic [7:0] msg_length;

	
	always@ (posedge clk or negedge rst_n) begin
		if (rst_n == 0) temp_i <= 0;
		else if(en_i) temp_i <= s_rddata;
		else temp_i <= temp_i;
	end
	
	always@ (posedge clk or negedge rst_n) begin
		if (rst_n == 0) temp_j <= 0;
		else if(en_j) temp_j <= s_rddata;
		else temp_j <= temp_j;
	end
	
	always@ (posedge clk or negedge rst_n) begin
		if (rst_n == 0) temp_pad <= 0;
		else if(en_pad) temp_pad <= s_rddata;
		else temp_pad <= temp_pad;
	end
	
	always@ (posedge clk or negedge rst_n) begin
		if (rst_n == 0) temp_ct <= 0;
		else if(en_ct) temp_ct <= ct_rddata;
		else temp_ct <= temp_ct;
	end
	
	always@ (posedge clk or negedge rst_n) begin
		if (rst_n == 0) temp_pt <= 8'bz;
		else if(en_pt) temp_pt <= temp_pad ^ temp_ct;
		else temp_pt <= temp_pt;
	end
	
	
	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 0) begin
			j_val <= 0;
			sum_val <= 0;
		end else if(en_cal_j)						
			j_val <= j_val + temp_i;		
		else if(en_sum)
			sum_val <= temp_i + temp_j;		
	end


	always_ff @(posedge clk or negedge rst_n) begin
		if (rst_n == 0)	
			i_val <= 0;
		else if(increment_i) 
			i_val <= i_val + 1'b1;
		else 
			i_val <= i_val;
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if (rst_n == 0)
			k_val <= 0;
		else if(increment_k) 
			k_val <= k_val + 1'b1;
		else 
			k_val <= k_val;
	end
	
	
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (rst_n == 0)
			msg_length <= 0;
		else if(en_len) 
			msg_length <= ct_rddata;
		else 
			msg_length <= msg_length;
	end
	
	
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= `Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			`Start:			next_state = `Wait;
			`Wait:			if(en & k_val == 0) next_state = `Get_msg_len;
							else if(en) next_state = `Inc_i;
							else next_state = `Wait;
			`Inc_i:			next_state = `Get_si;
			`Get_si:		next_state = `Store_si;
			`Store_si:		next_state = `Cal_j;
			`Cal_j:			next_state = `Get_sj;
			`Get_sj:		next_state = `Store_sj;
			`Store_sj:		next_state = `Write_i_to_j;
			`Write_i_to_j:	next_state = `Write_j_to_i;
			`Write_j_to_i:	next_state = `Sum_si_sj;
			`Sum_si_sj:		next_state = `Get_padk; 
			`Get_padk:		next_state = `Store_padk;
			`Store_padk:	next_state = `Get_CT;
			`Get_CT:		next_state = `Pad_xor_CT;
			`Pad_xor_CT:	next_state = `Store_PT;
			`Store_PT:		next_state = `Check_k;
			`Check_k:		if(k_val == msg_length) next_state = `Wait;
							else next_state = `Inc_k;
			`Inc_k:			next_state = `Inc_i;												
			//`Finish:		next_state = `Wait;
			
			`Get_msg_len: 	next_state = `Wait_len;
			`Wait_len: 		next_state = `Store_len;
			`Store_len: 	next_state = `Inc_k;
			
			default: 		next_state = 5'bxxxxx;
		endcase 
	end
	
	always_comb begin
		case(state)
			`Start:			begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0; 
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0; en_pt = 0; en_len = 0; data_out_sel = 0; end						
			`Wait:			begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 1; en_cal_j = 0; en_sum = 0; en_pt = 0; en_len = 0; data_out_sel = 0; end				
			`Inc_i:			begin   s_wren = 0; increment_i = 1; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end			
			`Get_si:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end			
			`Store_si:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 1; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end			
			`Cal_j:			begin   s_wren = 0; increment_i = 0; addr_sel = 2'b01; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 1; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end			
			`Get_sj:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b01; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Store_sj:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b01; en_i = 0; en_j = 1; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Write_i_to_j:	begin   s_wren = 1; increment_i = 0; addr_sel = 2'b01; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Write_j_to_i:	begin   s_wren = 1; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 1; end
			`Sum_si_sj:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b10; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 1;	en_pt = 0; en_len = 0; data_out_sel = 0; end 
			`Get_padk:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b10; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Store_padk:	begin   s_wren = 0; increment_i = 0; addr_sel = 2'b10; en_i = 0; en_j = 0; en_pad = 1; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Get_CT:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 1; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0; en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Pad_xor_CT:	begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 1; en_len = 0; data_out_sel = 0; end
			`Store_PT:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 1;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Inc_k:			begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 1; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			`Check_k:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end							
			//`Finish:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
			//						increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			
			`Get_msg_len:	begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 1; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 1; data_out_sel = 0; end
			`Wait_len: 		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 0;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 1; en_len = 0; data_out_sel = 1; end
			`Store_len:		begin   s_wren = 0; increment_i = 0; addr_sel = 2'b00; en_i = 0; en_j = 0; en_pad = 0; en_ct = 0; pt_wren = 1;
									increment_k = 0; rdy = 0; en_cal_j = 0; en_sum = 0;	en_pt = 0; en_len = 0; data_out_sel = 0; end
			
			default: 		begin   s_wren = 1'bx; increment_i = 1'bx; addr_sel = 2'bxx; en_i = 1'bx; en_j = 1'bx; en_pad = 1'bx; en_ct = 1'bx; pt_wren = 1'bx;
									increment_k = 1'bx; rdy = 1'bx; en_cal_j = 1'bx; en_sum = 1'bx;	en_pt = 1'bx; en_len = 1'bx; data_out_sel = 1'bx; end
		endcase 
	end
	
	
	assign pt_wrdata = temp_pt;
	assign ct_addr = k_val;
	assign pt_addr = k_val;


	assign s_wrdata = data_out_sel ? temp_j : temp_i;
	assign s_addr = addr_sel[1] ? (addr_sel[0] ? 8'b0 : sum_val) : (addr_sel[0] ? j_val : i_val);

endmodule: prga
