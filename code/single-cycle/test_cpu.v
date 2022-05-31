`timescale 1ns/1ps
module test_cpu();
	
	reg reset;
	reg clk;
	wire [31:0] out;
	
	CPU cpu1(reset, clk, out);
	
	initial begin
		reset = 1;
		clk = 1;
		#100 reset = 0;
	end
	
	always #50 clk = ~clk;
		
endmodule
