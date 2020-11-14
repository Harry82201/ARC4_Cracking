`timescale 1ps / 1ps

module tb_rtl_init();

// Your testbench goes here.
    logic clk, rst_n, en, rdy, wren;
	logic [7:0] addr, wrdata;
	
	init init_rtl(.clk, .rst_n, .en, .rdy, .addr, .wrdata, .wren);

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
		#11000;
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
		#40;
		en = 0;
		#5200;
		en = 1;
		#10;
		en = 0;
		#5200;
		en = 1;
		#10;
		en = 0;
	end

endmodule: tb_rtl_init
