`timescale 1ps / 1ps

module tb_rtl_task4();

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
	
	task4 task4_rtl(.CLOCK_50, .KEY, .SW, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);
	
	initial begin
      CLOCK_50 = 0;
      forever #1 CLOCK_50 = ~CLOCK_50;
   end
	
	
	initial begin
		$readmemh("test2.memh", task4_rtl.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
		#132000;
		$readmemh("task4_test1.memh", task4_rtl.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
		#15000;
		$readmemh("task4_test2.memh", task4_rtl.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
	end
	 
	initial begin
		KEY[3] = 1;
		#10;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
		#134000;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
		#15000;
		KEY[3] = 0;
		#10;
		KEY[3] = 1;
	end

endmodule: tb_rtl_task4
