/*
	Simple testbench for the counter.
*/

`timescale 1ns / 1ns // `timescale <time_unit> / <time_precision>

`include "../src/counter.v"

module counter_tb;

	parameter BW = 3;
	
	// inputs
	reg 		rst_i = 1'b1;
	reg 		clk_i = 1'b0;
	wire [BW-1:0] 	cnt_val; 
	
	//DUT
	counter 
		#(BW)
		counter_dut (
			.clk_i(clk_i),
			.rst_i(rst_i),
			.counter_val_o(cnt_val)
		);
	
	//Generate clock
	/* verilator lint_off STMTDLY */
	always #5 clk_i = ~clk_i; // wait 5 time units (e.g. 5ns)
	/* verilator lint_on STMTDLY */
	
	initial begin
		$dumpfile("counter_tb.vcd");
		$dumpvars;
	
		/* verilator lint_off STMTDLY */
		#50 rst_i = 1'b0; // deassert reset
		#200 $finish; // finish
		/* verilator lint_on STMTDLY */
	end
	
endmodule // counter_tb
