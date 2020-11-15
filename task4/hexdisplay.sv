module hexdisplay(input [4:0] char, output logic [6:0] HEX);
	
	always_comb begin
		case(char)
			5'b00000: HEX = 7'b1000000; //0
			5'b00001: HEX = 7'b1111001;
			5'b00010: HEX = 7'b0100100;
			5'b00011: HEX = 7'b0110000;
			5'b00100: HEX = 7'b0011001;
			5'b00101: HEX = 7'b0010010;
			5'b00110: HEX = 7'b0000010;
			5'b00111: HEX = 7'b1111000;
			5'b01000: HEX = 7'b0000000;
			5'b01001: HEX = 7'b0010000; //9
			5'b01010: HEX = 7'b0001000; //A
			5'b01011: HEX = 7'b0000011; //B
			5'b01100: HEX = 7'b1000110; //C
			5'b01101: HEX = 7'b0100001; //D
			5'b01110: HEX = 7'b0000110; //E
			5'b01111: HEX = 7'b0001110; //F
			5'b10000: HEX = 7'b0111111; //-
			5'b11111: HEX = 7'b1111111; //clear
			default: HEX = 7'b1111111;
		endcase
	 end
	
endmodule

