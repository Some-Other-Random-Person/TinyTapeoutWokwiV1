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

//loosely based on cordic implementations for similar applications as found on github
//for example: https://github.com/ShanDash/Cordic-Algorithm/tree/main

module cordic_sin_cos (
        input clk,  
        input wire start,    
        input wire reset,
        input [15:0] i_angle, 
        output wire signed [15:0] sine_output, 
        output wire signed [15:0] cosine_output,  
        output reg done 
);
/* verilator lint_off BLKSEQ */

function [15:0] degreeConverter; 
        input [15:0] angle_deg;
        reg [15:0] radians_angle;
        begin
            radians_angle = angle_deg * 16'd286; //conv factor
            degreeConverter = radians_angle;
        end
endfunction

reg signed [15:0] sine;
reg signed [15:0] cosine;
reg signed [15:0] sine_out;
reg signed [15:0] cosine_out;

assign sine_output = sine_out;
assign cosine_output = cosine_out;
//cordic
parameter I_MAX = 16; //iterations
reg [15:0] angle_table [0:15];  //init on reset
reg signed [15:0] x, y, z; 
reg signed [15:0] x_temp, y_temp, z_temp; 

reg [15:0] iterCount; 

reg signed [15:0] input_angle;
reg signed [15:0] angle;
reg signed [15:0] j;
reg [5:0] i;

localparam  START = 2'b00, //init
            ITERATING = 2'b01, 
            DONE = 2'b10; 

reg [1:0] quadrant;
reg [1:0] state;
reg on;

// Sequential process with single clock edge and async reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset all registers
        on        <= 1'b0;
        state     <= START;
        done      <= 1'b0;
        iterCount <= 0;
        x         <= 0;
        y         <= 0;
        z         <= 0;
        sine_out  <= 0;
        cosine_out<= 0;
    end else begin
        // Synchronous start control
        if (start) begin
            on <= 1'b1;
        end

        case (state)
            START: begin
                if (on) begin
                    // Initialize angle table
                    angle_table[0] <= 16'h3244;
                    angle_table[1] <= 16'h1DAC;
                    angle_table[2] <= 16'h0FAE;
                    angle_table[3] <= 16'h07F5;
                    angle_table[4] <= 16'h03FF;
                    angle_table[5] <= 16'h0200;
                    for (i = 6; i < I_MAX; i = i+1)
                        angle_table[i] <= angle_table[i-1] >>> 1;

                    // Normalize input angle
                    input_angle <= i_angle;
                    if (input_angle == 360) input_angle <= 0;
                    if (input_angle > 180)  input_angle <= input_angle - 360;
                    else if (input_angle < -180) input_angle <= input_angle + 360;

                    j <= input_angle;

                    // Quadrant selection
                    if (j >= -180 && j <= -91) begin
                        angle    <= degreeConverter(180 + j);
                        quadrant <= 2'b10;
                    end else if (j >= -90 && j <= -1) begin
                        angle    <= degreeConverter(j);
                        quadrant <= 2'b11;
                    end else if (j >= 0 && j <= 89) begin
                        angle    <= degreeConverter(j);
                        quadrant <= 2'b00;
                    end else if (j >= 90 && j <= 179) begin
                        angle    <= degreeConverter(180 - j);
                        quadrant <= 2'b01;
                    end

                    // Initialize CORDIC variables
                    x         <= 16'h26DD;
                    y         <= 16'h0000;
                    z         <= angle;
                    iterCount <= 0;
                    done      <= 1'b0;
                    state     <= ITERATING;
                end
            end

            ITERATING: begin
                if (z[15]) begin
                    x_temp <= x + (y >>> iterCount);
                    y_temp <= y - (x >>> iterCount);
                    z_temp <= z + angle_table[iterCount];
                end else begin
                    x_temp <= x - (y >>> iterCount);
                    y_temp <= y + (x >>> iterCount);
                    z_temp <= z - angle_table[iterCount];
                end
                iterCount <= iterCount + 1;
                state     <= DONE;
            end

            DONE: begin
                x <= x_temp;
                y <= y_temp;
                z <= z_temp;

                if (iterCount == I_MAX) begin
                    cosine <= x_temp;
                    sine   <= y_temp;

                    if (i_angle == 180) begin
                        sine_out   <= 16'h0000;
                        cosine_out <= 16'hC006;
                    end else begin
                        case (quadrant)
                            2'b00: begin sine_out <= sine;   cosine_out <= cosine;   end
                            2'b01: begin sine_out <= sine;   cosine_out <= -cosine;  end
                            2'b10: begin sine_out <= -sine;  cosine_out <= -cosine;  end
                            2'b11: begin sine_out <= sine;   cosine_out <= cosine;   end
                        endcase
                    end

                    done <= 1'b1;
                    on   <= 1'b0;
                    state<= START;
                end else begin
                    state <= ITERATING;
                end
            end

            default: state <= START;
        endcase
    end
end


// always @(posedge clk or posedge reset or posedge start) begin
//     if (start) begin
//         on <= 1;
//     end
//     if (reset) begin      
//         on <= 0;
//     end else begin
        
        
//         case(state)
//             START: begin
//                 if (on) begin
//                     angle_table[0] = 16'h3244; // tan^-1 (2^-0)
//                     angle_table[1] = 16'h1DAC; // tan^-1 (2^-1)
//                     angle_table[2] = 16'h0FAE; // tan^-1 (2^-2)
//                     angle_table[3] = 16'h07F5; // tan^-1 (2^-3)
//                     angle_table[4] = 16'h03FF; // tan^-1 (2^-4)
//                     angle_table[5] = 16'h0200; // tan^-1 (2^-5)
//                     /* verilator lint_off WIDTH */
//                     for (i = 6; i < I_MAX; i = i+1)
//                         angle_table[i] = angle_table[i-1]>>>1; 
//                     /* verilator lint_on WIDTH */
//                     //$display("Reached");
//                     input_angle = i_angle;
//                     if (input_angle == 360) begin
//                         input_angle = 0;
//                     end
//                     //$display ("i_angle1 = %f",input_angle);
//                     if (input_angle > 180) begin
//                         input_angle = input_angle - 360;
//                     end
//                     else if (input_angle < -180) begin
//                         input_angle = input_angle + 360;
//                     end
//                     j <= input_angle;
//                     //$display ("i_angle2 = %f",j);
//                     if (j >= -180 && j <= -91) begin
//                         angle = degreeConverter(180 + j);
//                         quadrant = 2'b10;
//                     end
//                     else if (j >= -90 && j <= -1) begin
//                         angle = degreeConverter(j);
//                         quadrant = 2'b11;
//                     end
//                     else if (j >= 0 && j <= 89) begin
//                         angle = degreeConverter(j);
//                         quadrant =2'b00;
//                     end
//                     else if (j >= 90 && j <= 179) begin
//                         angle = degreeConverter(180 - j);
//                         quadrant = 2'b01;
//                     end 
//                     //$display ("i_angle= %f; angleRAD = %h, %f",input_angle, angle, quadrant);
//                     x = 16'h26DD; //cordic
//                     y = 16'h0000;
//                     z = angle;
//                     iterCount = 0;
//                     done = 0;
//                     state = ITERATING; end end
                    
//             ITERATING: begin
//                 /* verilator lint_off WIDTH */
//                 if (z[15]) begin
//                     x_temp = x + (y >>> iterCount);
//                     y_temp = y - (x >>> iterCount);
//                     z_temp = z + angle_table[iterCount];
//                     state = DONE; 
//                 end else begin
//                     x_temp = x - (y >>> iterCount);
//                     y_temp = y + (x >>> iterCount);
//                     z_temp = z - angle_table[iterCount]; 
//                 end
//                 /* verilator lint_on WIDTH */
//                 iterCount = iterCount + 1;
//                 state = DONE; 
//             end
                
//             DONE: begin
//                 x = x_temp;
//                 y = y_temp;
//                 z = z_temp;
//                 if (iterCount == I_MAX) begin
//                     cosine = x_temp;
//                     sine = y_temp;
//                     //$display ("sine= %h; cosine= %h",sine, cosine);
//                     if (i_angle == 180) begin
//                         sine_out = 16'h0000;
//                         cosine_out = 16'hC006;
//                     end else begin
//                         if (quadrant == 2'b00) begin
//                             sine_out = sine;
//                             cosine_out = cosine; 
//                         end else if (quadrant == 2'b01) begin
//                             sine_out = sine;
//                             cosine_out = -cosine; 
//                         end else if (quadrant == 2'b10) begin
//                             sine_out = -sine;
//                             cosine_out = -cosine; 
//                         end else begin
//                             sine_out = sine;
//                             cosine_out = cosine; 
//                         end
//                     end
//                     done = 1;
//                     on <= 0;
//                     state = START; 
//                 end else begin
//                     state = ITERATING; 
//                 end
//             end     
//             default: begin
//                 state = START; 
//             end
//         endcase 
//     end
// end
//initial angle table

/* verilator lint_off BLKSEQ */   

endmodule
