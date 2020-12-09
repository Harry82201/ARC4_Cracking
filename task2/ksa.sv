`define Start 				4'b0000		
`define Wait 				4'b0001
`define Get_si				4'b0010
`define Store_si 			4'b0011
`define Calculate_j		    4'b0100
`define Get_sj				4'b0101
`define Store_sj			4'b0110
`define Write_si_to_sj	    4'b0111
`define Write_sj_to_si	    4'b1000
`define Inc_i				4'b1001
`define Finish				4'b1010

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
    logic [3:0] state, next_state;
	logic [7:0] count = 0;
	logic [7:0] j_val = 0;
	logic [1:0] modulo_count = 0;
	logic [7:0] temp_si = 0;
	logic [7:0] temp_sj= 0;
	logic [7:0] key_val;

	logic addr_sel;
	logic wrdata_sel;
	logic en_si;
	logic en_sj;
	logic en_calc_j;
	logic increment;
	 
	assign wrdata = wrdata_sel ? temp_sj : temp_si;
	assign addr = addr_sel ? j_val : count;
	 
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= `Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			`Start: 			next_state = `Wait;
			`Wait: 				if (en) next_state = `Get_si;
								else next_state = `Wait;
			`Get_si:			next_state = `Store_si;					
			`Store_si:			next_state = `Calculate_j;			
			`Calculate_j:		next_state = `Get_sj;		
			`Get_sj:			next_state = `Store_sj;
			`Store_sj:			next_state = `Write_si_to_sj;
			`Write_si_to_sj:	next_state = `Write_sj_to_si;										
			`Write_sj_to_si:	next_state = `Inc_i;				
			`Inc_i:				if (count == 255) next_state = `Wait;
								else next_state = `Get_si;					
			//`Finish:			next_state = `Wait;
			default: 			next_state = 4'bxxxx;
		endcase 
	end
	
	always_comb begin
		case(state)
			`Start: 			begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end									
			`Wait: 				begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 1; end
			`Get_si:			begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end					
			`Store_si:			begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 1; en_sj = 0; en_calc_j = 0; rdy = 0; end			
			`Calculate_j:		begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 1; rdy = 0; end		
			`Get_sj:			begin   wren = 0; increment = 0; addr_sel = 1; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end
			`Store_sj:			begin   wren = 0; increment = 0; addr_sel = 1; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 1; en_calc_j = 0; rdy = 0; end
			`Write_si_to_sj:	begin   wren = 1; increment = 0; addr_sel = 1; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end										
			`Write_sj_to_si:	begin   wren = 1; increment = 0; addr_sel = 0; wrdata_sel = 1; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end				
			`Inc_i:				begin   wren = 0; increment = 1; addr_sel = 0; wrdata_sel = 0; 
                                        en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end					
			//`Finish:			begin   wren = 0; increment = 0; addr_sel = 0; wrdata_sel = 0; 
            //                          en_si = 0; en_sj = 0; en_calc_j = 0; rdy = 0; end
			default: 			begin   wren = 1'bx; increment = 1'bx; addr_sel = 1'bx; wrdata_sel = 1'bx; 
                                        en_si = 1'bx; en_sj = 1'bx; en_calc_j = 1'bx; rdy = 1'b1; end
		endcase 
	end
	
	always_comb begin
		modulo_count = count % 2'b11;
		case(modulo_count)
			2'b00	:	key_val = key[23:16];
			2'b01	:	key_val = key[15:8];
			2'b10	:	key_val = key[7:0];
			default: key_val = 0;
		endcase
	end


	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) temp_si <= 0;
		else if(en_si) temp_si <= rddata;
		else temp_si <= temp_si;
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) temp_sj <= 0;
		else if(en_sj) temp_sj <= rddata;
		else temp_sj <= temp_sj;
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) j_val <= 0;
		else if(en_calc_j) j_val <= temp_si + key_val + j_val;
		else j_val <= j_val;
	end


	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) count <= 0;
		else if(increment) count <= count + 1'b1;
		else count <= count;
	end

endmodule: ksa
