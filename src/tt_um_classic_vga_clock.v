// Copyright 2025 A Person
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//`include "classic_vga_clock.v"

module tt_um_classic_vga_clock (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_out[7:1] = 7'b0; //set to 0
    assign uio_oe  = 8'b000_0001;
    wire _unused = &{ena, uio_in, ui_in[5], ui_in[6], ui_in[7], 1'b0};

    wire hsync, vsync, black_white, buzzer_out;
    
    wire hour_in                = ui_in[0];
    wire min_in                 = ui_in[1];
    wire sec_in                 = ui_in[2];
    wire al_in                  = ui_in[3];
    wire al_on_off_toggle_in    = ui_in[4];

    //compatibility with the VGA PMOD
    // https://tinytapeout.com/specs/pinouts/#common-peripherals
    assign uo_out[0] = black_white;
    assign uo_out[1] = black_white;
    assign uo_out[2] = black_white;
    assign uo_out[3] = vsync;
    assign uo_out[4] = black_white;
    assign uo_out[5] = black_white;
    assign uo_out[6] = black_white;
    assign uo_out[7] = hsync;

    assign uio_out[0] = buzzer_out;

    classic_vga_clock uut (
        .video_clk(clk),
        .reset_n(rst_n),
        .hour_in(hour_in),
        .min_in(min_in),
        .sec_in(sec_in),
        .al_in(al_in),
        .al_on_off_toggle_in(al_on_off_toggle_in),
        .buzzer_out(buzzer_out),
        .vga_horizSync(hsync),
        .vga_vertSync(vsync),
        .black_white(black_white)
    );

endmodule