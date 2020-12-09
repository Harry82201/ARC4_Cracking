`timescale 1ps / 1ps

module tb_syn_crack();

// Your testbench goes here.
    logic clk, rst_n, en, rdy, key_valid;
	logic [23:0] key;
	logic [7:0] ct_addr, ct_rddata;
	
	crack crack_4_syn(.clk, .rst_n, .en, .rdy, .key, .key_valid, .ct_addr, .ct_rddata);
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
	 
	initial begin
		rst_n = 1;
		#10;
		rst_n = 0;
		#10;
		rst_n = 1;
		#12000;
		rst_n = 0;
		#10;
		rst_n = 1;
		#1000;
		rst_n = 0;
		#10;
		rst_n = 1;
	end

	initial begin
		en = 1;
		forever #1100 en = ~en;
	end

	initial begin
		ct_rddata = 8'b00000000;
		forever #100 ct_rddata = ct_rddata + 8'b00000001;
	end
	 
	/*
	initial begin
		en = 1;
		ct_rddata = 8'b00000000;
		#40;
		en = 0;
		ct_rddata = 8'b00010010;
		#100;
		ct_rddata = 8'b00001110;
		//crack_rtl.s_key = 24'b1111_1111_1111_1111_1111_1110; //no key found
		#100;
		ct_rddata = 8'b00110111;
		#100;
		ct_rddata = 8'b0011111;
		#200;
		ct_rddata = 8'b00110101;
		#200;
		ct_rddata = 8'b00110000;
		#400;
		ct_rddata = 8'b00110001;
		#11800;
		en = 1;
		#10;
		en = 0;
		#300;
		ct_rddata = 8'b00111001;
		#600;
		ct_rddata = 8'b01011101;
		#400;
		ct_rddata = 8'b10111011;
		#400;
	end
	*/


endmodule: tb_syn_crack
