module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here
    parameter Start = 3'b000;
	parameter Wait = 3'b001;
	parameter Write = 3'b010;
	parameter Inc_I = 3'b011;
	//parameter Finish = 3'b100;

	logic [2:0] state, next_state;
	logic [7:0] count = 0;
	logic increment;
	
	assign addr = count;
	assign wrdata = count;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) count <= 0;
		else if(increment) count <= count + 1;
		else count <= count;
	end
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(rst_n == 0) state <= Start;
		else state <= next_state;
	end
	
	always_comb begin
		case(state)
			Start: 	next_state = Wait;
			Wait:	if(en == 1) next_state = Write;
					else next_state = Wait;
			Write:	next_state = Inc_I;
			Inc_I:	if(count == 255) next_state = Wait;
					else next_state = Write;				
			default: next_state = 3'bxxx;
		endcase
	end
	
	always_comb begin
		case(state)
			Start: 	begin rdy = 0; wren = 0; increment = 0; end						
			Wait:	begin rdy = 1; wren = 0; increment = 0; end
			Write:	begin rdy = 0; wren = 1; increment = 0; end
			Inc_I:	begin rdy = 0; wren = 0; increment = 1; end
			default: begin rdy = 1'bx; wren = 1'bx; increment = 1'bx; end
		endcase
	end

endmodule: init