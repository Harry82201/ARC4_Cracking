module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
    logic [7:0] address_to_mem, addr_init, addr_ksa, addr_prga;
	logic [7:0] data_to_mem, wrdata_init, wrdata_ksa, wrdata_prga;
	logic [7:0] data_from_mem;
	logic s_wren, wren_init, wren_ksa, wren_prga;
	logic en_init, en_ksa, en_prga;
	logic rdy_init, rdy_ksa, rdy_prga;
	  
	arc4_ctrl arc4_ctrl_ins(.clk, .rst_n, .en, .rdy_init, .rdy_ksa, .rdy_prga, .en_init, .en_ksa, .en_prga, .rdy);

    s_mem s(.address(address_to_mem), .clock(clk), .data(data_to_mem), .wren(s_wren), .q(data_from_mem));
    init i(.clk, .rst_n, .en(en_init), .rdy(rdy_init), .addr(addr_init), .wrdata(wrdata_init), .wren(wren_init));
    ksa k(.clk, .rst_n, .en(en_ksa), .rdy(rdy_ksa), .key, .addr(addr_ksa), .rddata(data_from_mem), .wrdata(wrdata_ksa), .wren(wren_ksa));
    prga p(.clk, .rst_n, .en(en_prga), .rdy(rdy_prga), .key, .s_addr(addr_prga), .s_rddata(data_from_mem), .s_wrdata(wrdata_prga), 
            .s_wren(wren_prga), .ct_addr, .ct_rddata, .pt_addr, .pt_rddata, .pt_wrdata, .pt_wren);

    assign address_to_mem = (~rdy_init) ? addr_init : ((~rdy_ksa) ? addr_ksa : addr_prga);
	assign data_to_mem = (~rdy_init) ? wrdata_init : ((~rdy_ksa) ? wrdata_ksa : wrdata_prga);
	assign s_wren = (~rdy_init) ? wren_init : ((~rdy_ksa) ? wren_ksa : wren_prga);

endmodule: arc4

module arc4_ctrl(input logic clk, input logic rst_n, input logic en,
					input logic rdy_init, input logic rdy_ksa, input logic rdy_prga, 
					output logic en_init, output logic en_ksa, output logic en_prga, output logic rdy);
	
	parameter Start = 4'b0000;
	parameter Start_init = 4'b0001;
	parameter Wait_init = 4'b0010;
	parameter Finish_init = 4'b0011;
	parameter Start_ksa = 4'b0100;
	parameter Wait_ksa = 4'b0101;
	parameter Finish_ksa = 4'b0110;
	parameter Start_prga = 4'b0111;
	parameter Wait_prga = 4'b1000;
	parameter Finish = 4'b1001;
	parameter Wait = 4'b1010;
	
	logic [3:0] state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 			next_state = Wait;				
			Wait: 			if(rdy_init & en) next_state = Start_init;
							else next_state = Wait;
			Start_init: 	next_state = Wait_init;
			Wait_init: 		if(rdy_init) next_state = Finish_init;
							else next_state = Wait_init;
			Finish_init: 	if(rdy_ksa) next_state = Start_ksa;
							else next_state = Finish_init;
			Start_ksa: 		next_state = Wait_ksa;
			Wait_ksa: 		if(rdy_ksa) next_state = Finish_ksa;
							else next_state = Wait_ksa;
			Finish_ksa: 	if(rdy_prga) next_state = Start_prga;
							else next_state = Finish_ksa;		
			Start_prga: 	next_state = Wait_prga;
			Wait_prga: 		if(rdy_prga) next_state = Finish;
							else next_state = Wait_prga;
			Finish: 		next_state = Finish;
			default: 		next_state = 4'bxxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 			begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end
			Wait: 			begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 1; end
			Start_init: 	begin en_init = 1; en_ksa = 0; en_prga = 0; rdy = 0; end
			Wait_init: 		begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end
			Finish_init:	begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end
			Start_ksa: 		begin en_init = 0; en_ksa = 1; en_prga = 0; rdy = 0; end
			Wait_ksa: 		begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end
			Finish_ksa: 	begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end 
			Start_prga: 	begin en_init = 0; en_ksa = 0; en_prga = 1; rdy = 0; end
			Wait_prga: 		begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 0; end
			Finish: 		begin en_init = 0; en_ksa = 0; en_prga = 0; rdy = 1; end
			default: 		begin en_init = 1'bx; en_ksa = 1'bx; en_prga = 1'bx; rdy = 1'bx; end
		endcase
	end
	
endmodule