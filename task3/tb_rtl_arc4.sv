`timescale 1ps / 1ps

module tb_rtl_arc4();

// Your testbench goes here.
    logic clk, rst_n, en, rdy, pt_wren;
	logic [7:0] ct_addr, pt_addr;
	logic [7:0] ct_rddata, pt_rddata;
	logic [7:0] pt_wrdata;
	logic [23:0] key;
	
	arc4 arc4_rtl(.clk, .rst_n, .en, .rdy, .key,.ct_addr, .ct_rddata,
					.pt_addr, .pt_rddata, .pt_wrdata, .pt_wren);
					  
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
		#8000;
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
		ct_rddata = 8'b0;
		pt_rddata = 8'b0;
		key = 24'b0;
		#10;
		en = 0; 
		#300;
		ct_rddata = 8'b1001;
		pt_rddata = 8'b110001;
		key = 24'b110100110;
		#300;
		ct_rddata = 8'b1011;
		pt_rddata = 8'b1101010;
		key = 24'b11010011010;
		#300;
		ct_rddata = 8'b1001;
		pt_rddata = 8'b110001;
		key = 24'b110100110;
		#7500;
		en = 1;
		#10;
		en = 0;
	end

endmodule: tb_rtl_arc4
