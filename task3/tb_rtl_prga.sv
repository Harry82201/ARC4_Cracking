`timescale 1ps / 1ps

module tb_rtl_prga();

// Your testbench goes here.
    logic clk, rst_n, en, rdy, s_wren, pt_wren;
	logic [7:0] s_addr, ct_addr, pt_addr;
	logic [7:0] s_rddata, ct_rddata, pt_rddata;
	logic [7:0] s_wrdata, pt_wrdata;
	logic [23:0] key;
	
	prga prga_rtl(  .clk, .rst_n, .en, .rdy, .key, .s_addr, .s_rddata, .s_wrdata, .s_wren,
					.ct_addr, .ct_rddata, .pt_addr, .pt_rddata, .pt_wrdata, .pt_wren);
	
	initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
	 
	initial begin
		rst_n = 1;
		#10;
		rst_n = 0;
		#10;
		rst_n = 1;
		#4500;
		rst_n = 0;
		#10;
		rst_n = 1;
		#1000;
		rst_n = 0;
		#10;
		rst_n = 1;
	end
	 
	initial begin
		en = 0;
		s_rddata = 8'b0;
		ct_rddata = 8'b0;
		pt_rddata = 8'b0;
		key = 24'b0;
		#25;
		en = 1;
		#10;
		en = 0;
		s_rddata = 8'b1100;
		ct_rddata = 8'b1001010;
		pt_rddata = 8'b101110;
		#300;
		s_rddata = 8'b1000110;
		ct_rddata = 8'b1111001;
		pt_rddata = 8'b11001100;
		key = 24'b1011001;
		#300;
		s_rddata = 8'b101110;
		ct_rddata = 8'b11110010;
		pt_rddata = 8'b11111100;
		key = 24'b101111010001;
		#5000;
		en = 1;
		s_rddata = 8'b1110;
		ct_rddata = 8'b111010;
		pt_rddata = 8'b1111001;
		key = 24'b1011010001;
		#10;
		en = 0;
		#300;
		s_rddata = 8'b1011101;
		ct_rddata = 8'b1110010;
		pt_rddata = 8'b11111001;
		key = 24'b101111010001001;
		#5500;
		en = 1;
		#10;
		en = 0;
		s_rddata = 8'b1101001;
		ct_rddata = 8'b1100100;
		pt_rddata = 8'b1101001;
		key = 24'b1011110100010001;
	end

endmodule: tb_rtl_prga
