`timescale 1ps / 1ps

module tb_rtl_ksa();
    // Your testbench goes here.
    logic clk, rst_n, en, rdy, wren;
	logic [7:0] addr, rddata, wrdata;
	logic [23:0] key;
	
	ksa ksa_rtl(.clk, .rst_n, .en, .rdy, .key, .addr, .rddata, .wrdata, .wren);
	
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
		#21000;
		rst_n = 0;
		#10;
		rst_n = 1;
	end
	 
	initial begin
		en = 1;
		rddata = 8'b0;
		key = 24'b0;
		#40;
		en = 0;
		#40;
		rddata = 8'b101;
		#80;
		rddata = 8'b10010;
		key = 24'b1001001110;
		#80;
		rddata = 8'b1111000;
		#21020;
		en = 1;
		#10;
		en = 0;
		#21000;
		en = 1;
		#10;
		en = 0;
	end

endmodule: tb_rtl_ksa
