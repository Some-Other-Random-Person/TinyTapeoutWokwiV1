`default_nettype none

`timescale 1ns / 1ps

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

//`include "button_debounce.v"
//`include "clockRenderer.v"
//`include "display_vga.v"

module classic_vga_clock (
    input wire clk,           //31.5 MHz
    input wire reset_n,             //Inverted reset line
    input wire hour_in,             //Hour increment button
    input wire min_in,              //Minute increment button 
    input wire sec_in,              //Second increment button
    input wire al_in,               //Alarmtime increment button
    input wire al_on_off_toggle_in, //Alarm On/Off toggle button

    output wire buzzer_out,         //Alarm buzzer output (!!! External Buffer + Driver required !!!)
    output wire vga_horizSync,      //Horizontal sync
    output wire vga_vertSync,       //Vertical sync
    output wire black_white         //black/white image line
);

/* verilator lint_off BLKSEQ */

wire reset = !reset_n;

wire sec_clock;
reg slow_clk;
wire buzzer_clk;
wire main_clk_trigg;

//wire slow_clk;

reg [5:0] seconds;
reg [5:0] minutes;
reg [3:0] hours;
reg [5:0] al_minutes;
reg [3:0] al_hours;
// reg [25:0] sec_counter;
// reg [19:0] slow_clk_counter;
// reg [13:0] buzzer_clk_counter;
// reg [15:0] bell_symb [0:15];

wire sec_adj_input, min_adj_input, hrs_adj_input, al_adj_input, al_on_off_toggle_line;
reg al_on, alarm;
assign buzzer_out = (alarm && sec_clock) ? buzzer_clk : 1'b0;

wire video_visible_range;  //within drawing range

wire drawClockhandPx;
wire alarmSymbDisp = al_on;
reg bellsig;
wire bellsigOut;
assign bellsigOut = alarmSymbDisp && bellsig ? 1'b1 : 1'b0;
//wire bellsigOut = alarmSymbDisp & bellsig
wire draw = drawClockhandPx | bellsigOut;

assign black_white = video_visible_range && draw ? 1'b1 : 1'b0;

wire [9:0] x_pix;          // X position for actual pixel.
wire [9:0] y_pix; 
reg [15:0] row_bell;
wire [9:0] x_offset_bell = 510;
wire [9:0] y_offset_bell = 200;
parameter SCALE = 5;
localparam DISP_WIDTH  = 16 * SCALE;
localparam DISP_HEIGHT = 16 * SCALE;
/* verilator lint_off WIDTH */
wire [9:0] h_adj = x_pix - x_offset_bell;
wire [9:0] v_adj = y_pix - y_offset_bell;

wire [3:0] fb_bell_x = h_adj / SCALE;
wire [3:0] fb_bell_y = v_adj / SCALE;
/* verilator lint_on WIDTH */
wire in_display_area = (h_adj < DISP_WIDTH) && (v_adj < DISP_HEIGHT);

// button_debounce hrsAdj (.regular_clk(clk), .slow_clk(slow_clk), .button_signal(hour_in), .output_pulse(hrs_adj_input), .reset(reset));
// button_debounce minAdj (.regular_clk(clk), .slow_clk(slow_clk), .button_signal(min_in), .output_pulse(min_adj_input), .reset(reset));
// button_debounce secAdj (.regular_clk(clk), .slow_clk(slow_clk), .button_signal(sec_in), .output_pulse(sec_adj_input), .reset(reset));
// button_debounce alAdj (.regular_clk(clk), .slow_clk(slow_clk), .button_signal(al_in), .output_pulse(al_adj_input), .reset(reset));
// button_debounce alOnOff (.regular_clk(clk), .slow_clk(slow_clk), .button_signal(al_on_off_toggle_in), .output_pulse(al_on_off_toggle_line), .reset(reset));
         

 reg [9:0] x_offs;
 reg [9:0] y_offs;
//parameter SCALE = 7;



//clockRenderer clockfaceRendering (.clk(clk), .slow_clk(slow_clk), .reset(reset), .hour(hours), .minute(minutes), .second(seconds), .al_hour(al_hours), .al_minute(al_minutes), .horizCounter(x_pix), .vertCounter(y_pix), .x_offset(x_offs), .y_offset(y_offs), .pixel_bw(drawClockhandPx));

display_vga vga_0 (.clk(clk), .sys_rst(reset), .hsync(vga_horizSync), .vsync(vga_vertSync), .horizPos(x_pix), .vertPos(y_pix), .active(video_visible_range));
/*
clock_div #(31500000, 100)   slowClock100Hz (.clk(clk), .reset(reset), .slower_clk_out_pulse(slow_clk));
clock_div #(31500000, 3150)   slowClockBuzzer (.clk(clk), .reset(reset), .slower_clk_out_pulse(buzzer_clk));
clock_div #(31500000, 1)   slowClock1Hz (.clk(clk), .reset(reset), .slower_clk_out_pulse(sec_clock));
clock_div #(31500000, 31500000)   mainClk (.clk(clk), .reset(reset), .slower_clk_out_pulse(main_clk_trigg));
*/

always @(posedge clk) begin
    if(reset) begin
        // bell_symb[0] <= 16'b0000001111000000;
        // bell_symb[1] <= 16'b0000011111100000;
        // bell_symb[2] <= 16'b0000110000110000;
        // bell_symb[3] <= 16'b0001100000011000;
        // bell_symb[4] <= 16'b0001100000011000;
        // bell_symb[5] <= 16'b0001100000011000;
        // bell_symb[6] <= 16'b0001100000011000;
        // bell_symb[7] <= 16'b0001000000001000;
        // bell_symb[8] <= 16'b0001000000001000;
        // bell_symb[9] <= 16'b0011000000001100;
        // bell_symb[10] <= 16'b0011000000001100;
        // bell_symb[11] <= 16'b0110000000000110;
        // bell_symb[12] <= 16'b1100000000000111;
        // bell_symb[13] <= 16'b1100000000000011;
        // bell_symb[14] <= 16'b1111111111111111;
        // bell_symb[15] <= 16'b0000001111000000;
        slow_clk = 0;
        seconds <= 0;
        minutes <= 0;
        hours <= 0;
        al_minutes <= 0;
        al_hours <= 0;
        bellsig = 0;

        //draw = 0;
        al_on <= 0;
        alarm <= 0;
        x_offs  = 25;
        y_offs = 15;
        //init Bell
        

    end 

    //      else if(seconds >= 60) begin
    //         seconds <= 0;
    //         minutes <= minutes + 1;
    //     end
    //      else if(minutes >= 60) begin
    //         minutes <= 0;
    //         hours <= hours + 1;
    //     end
    //     else if(hours >= 12) begin
    //         hours <= 0;
    //     end

    //     else if(al_minutes >= 60) begin
    //         al_minutes <= 0;
    //         al_hours <= al_hours + 1;
    //     end
    //     else if(al_hours >= 12) begin
    //         al_hours <= 0;
    //     end
    //     else if (sec_clock) begin
    //         seconds <= seconds + 1;
    //     end
    //     // adjustment buttons
    //     else if (sec_adj_input) begin
    //         seconds <= seconds + 1;
    //     end
    //     else if (min_adj_input) begin
    //         minutes <= minutes + 1;
    //     end
    //     else if (hrs_adj_input) begin
    //         hours <= hours + 1;
    //     end
    //     else if (al_adj_input) begin
    //         al_minutes <= al_minutes + 10;
    //     end
    //  else if (al_on_off_toggle_line && al_on) begin
    //     al_on <= 1'b0;
    //     alarm <= 1'b0;

    //  end else if (al_on_off_toggle_line && !al_on) begin

    //             al_on <= 1'b1;
            
    // end else if (al_on && hours == al_hours && minutes == al_minutes) begin
    //         alarm <= 1'b1;
    // end else begin
    //     // pos_x = fb_bell_x;
    //     // pos_y = fb_bell_x;
    //     // row_bell <= bell_symb[fb_bell_y];
    //     bellsig <= 1;
    //         //pixel_bw
    // end


end

endmodule
`default_nettype wire
