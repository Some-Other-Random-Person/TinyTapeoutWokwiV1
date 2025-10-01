/*
	Simple testbench for the counter.
*/

`timescale 1 ns / 1 ns // `timescale <time_unit> / <time_precision>

`include "counter.v"

module counter_tb;

	parameter BW = 3;

	reg clk_i = 1'b0;
	reg rst_i = 1'b1;
	wire [BW-1:0] counter_val;

	// DUT
	counter
		#(BW)
	counter_dut(
		.clk_i (clk_i),
		.rst_i (rst_i),
		.counter_val_o (counter_val)
	);

	// Generate clock
	/* verilator lint_off STMTDLY */
	always #5 clk_i = ~clk_i; // wait 5 time units (e.g. 5ns)
	/* verilator lint_on STMTDLY */

	initial begin
		$dumpfile("counter_tb.vcd");
		$dumpvars;

		/* verilator lint_off STMTDLY */
		#50 rst_i = 1’ b0 ; // deassert reset
		#200 $finish ; // finish
		/* verilator lint_on STMTDLY */
	end
endmodule // counter_tb