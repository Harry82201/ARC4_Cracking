`timescale 1ps / 1ps

module tb_syn_task3();

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
	
	//de1_gui gui(.SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);
	
	task3 task3_syn(.CLOCK_50, .KEY, .SW, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);
	
	initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end
	
	
	initial begin
		$readmemh("test2.memh", task3_syn.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
		SW = 10'b00_0001_1000;
	end
	 
	initial begin
		KEY[3] = 1;
		#10;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
		#5780; // change delay time!
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
	end


endmodule: tb_syn_task3
