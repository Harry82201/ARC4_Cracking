`timescale 1ps / 1ps

module tb_rtl_crack();

// Your testbench goes here.
    logic clk, rst_n, en, rdy, key_valid;
	logic [23:0] key;
	logic [7:0] ct_addr, ct_rddata;
	logic [23:0] low_key, high_key;
	
	crack crack_5_rtl(.clk, .rst_n, .en, .rdy, .key, .key_valid, .ct_addr, .ct_rddata, .low_key, .high_key);
    ct_mem ct_crack_5_rtl(.address(ct_addr), .clock(clk), .data(8'b0), .wren(1'b0), .q(ct_rddata));

	initial begin
		$readmemh("test2.memh", ct_crack_5_rtl.altsyncram_component.m_default.altsyncram_inst.mem_data);
	end
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
	
    initial begin
        low_key = 24'b1111_0000_0000_0000_0000_1000;
		high_key = 24'b1111_0000_0000_0000_0000_1001;
        #11000;
        low_key = 24'b0000_0000_0000_0000_0000_1000;
		high_key = 24'b0000_0000_0000_0000_0001_1111;
    end

	initial begin
        en = 1;
		rst_n = 1;
		#10;
		rst_n = 0;
		#10;
		rst_n = 1;
        #10;
		en = 0;
		#12000;
        en = 1;
        #10;
		rst_n = 0;
		#10;
		rst_n = 1;
        #10;
        en = 0;
		//#1000;
		//rst_n = 0;
		//#10;
		//rst_n = 1;
	end
	
    /*
	initial begin
		en = 1;
		low_key = 24'b1111_1111_1111_1111_0000_0000;
		high_key = 24'b1111_1111_1111_1111_0000_0001;
		ct_rddata = 8'b0;
		#40;
		en = 0;
		ct_rddata = 8'b10010;
		#100;
		ct_rddata = 8'b1110;
		//crack_rtl.s_key = 24'b1111_1111_1111_1111_1111_1110; //no key found
		#100;
		ct_rddata = 8'b110111;
		#100;
		ct_rddata = 8'b11111;
		#200;
		ct_rddata = 8'b110101;
		#200;
		ct_rddata = 8'b110000;
		#400;
		ct_rddata = 8'b110001;
		#11800;
		high_key = 24'b1111_1111_1111_1111_0000_1111;
		en = 1;
		#10;
		en = 0;
		#300;
		ct_rddata = 8'b111001;
		#600;
		ct_rddata = 8'b1011101;
		#400;
		ct_rddata = 8'b10111011;
	end
    */

endmodule: tb_rtl_crack
