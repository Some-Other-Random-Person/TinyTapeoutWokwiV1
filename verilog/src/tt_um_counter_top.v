/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`include "counter.v"

module tt_um_counter_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
	
	localparam BW = 8;
	
	// Declare wire to hold counter output
	wire [BW-1:0] counter_val;

	// Instantiate the counter module
	counter #(
		.BW(BW)  						// Set bit width parameter to local parameter BW
	) counter_inst (
		.clk_i(clk),                    // Connect clock
		.rst_i(~rst_n),                 // Connect reset (inverted since rst_n is active low)
		.counter_val_o(counter_val)     // Connect counter output
	);
  
	// All output pins must be assigned. If not used, assign to 0.
	assign uo_out  = counter_val;     	// Output the counter value
	assign uio_out = 0;
	assign uio_oe  = 0;

	// List all unused inputs to prevent warnings
	wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
