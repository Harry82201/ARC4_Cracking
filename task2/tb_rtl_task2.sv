`timescale 1ps / 1ps

module tb_rtl_task2();
    // Your testbench goes here.
    logic CLOCK_50;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [6:0] HEX0;
	logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;
	logic [9:0] LEDR;
	
	task2 task2_rtl(.CLOCK_50, .KEY, .SW, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);
	
	initial begin
        CLOCK_50 = 0;
        forever #1 CLOCK_50 = ~CLOCK_50;
    end
	
	initial begin
		SW = 10'b00_1101_0110;
		#5750;
		SW = 10'b11_0011_1100;
	end
	 
	initial begin
		KEY[3] = 1;
		#10;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
		#5780;
		//#1000;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
		#1000;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
	end


endmodule: tb_rtl_task2
