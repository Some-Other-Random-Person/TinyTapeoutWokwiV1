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

//`include "cordic_sin_cos.v"

module clockRenderer (
    input clk,
    input slow_clk,
    input reset,
    input [3:0] hour,     // 0–12
    input [5:0] minute,   
    input [5:0] second, 
    input [3:0] al_hour,
    input [5:0] al_minute,
    input  wire [9:0]  horizCounter,      
    input  wire [9:0]  vertCounter,     
    input  wire [9:0]  x_offset,     
    input  wire [9:0]  y_offset,    
    output wire         pixel_bw     
);
/* verilator lint_off BLKSEQ */

//framebuffer/memory
reg [63:0] framebuffer [0:63];
reg [63:0] row;

reg cordicStart;
reg cordicRunning;
wire cordDone;
reg [6:0] i, j, k, l, m;
reg refreshCycleRunning;
reg done;
reg start;
reg restartInhibit;

reg [15:0] currAngle;
wire [15:0] sinW;
wire [15:0] cosW;

reg pixel_bw_reg;
assign pixel_bw = pixel_bw_reg ? 1'b1 : 1'b0;

cordic_sin_cos cordicModule (.clk(clk), .reset(reset), .start(cordicStart), .i_angle(currAngle), .sine_output(sinW), .cosine_output(cosW), .done(cordDone));

/* verilator lint_off WIDTH */
//clockhand angles
wire [8:0] second_angle = (second * 6);   
wire [8:0] minute_angle = (minute * 6);   
wire [8:0] hour_angle = ((hour * 60) + minute) / 2; //assuming hour cannot reach 12
wire [8:0] alarm_angle = (al_hour * 30) + ((al_minute / 10) * 6);   //given incrementation by 10min
/* verilator lint_on WIDTH */

//states for statemachine
reg [1:0] state;
localparam  DRAW_HRS = 2'b00, 
            DRAW_MINS = 2'b01, 
            DRAW_SECS = 2'b10, 
            DRAW_ALARM = 2'b11;

//lengths of clockhands
// parameter MINUTE_LEN = 31;
// parameter HOUR_LEN = 22;
// parameter SEC_LEN = 27;
// parameter ALARM_LEN = 17;


//display parameters
parameter SCALE = 7;
localparam DISP_WIDTH  = 64 * SCALE;
localparam DISP_HEIGHT = 64 * SCALE;

/* verilator lint_off WIDTH */
wire [9:0] h_adj = horizCounter - x_offset;
wire [9:0] v_adj = vertCounter - y_offset;

wire [5:0] fb_x = h_adj / SCALE;
wire [5:0] fb_y = v_adj / SCALE;
/* verilator lint_on WIDTH */

wire in_display_area = (h_adj < DISP_WIDTH) && (v_adj < DISP_HEIGHT);
reg [63:0] dispRow;

reg signS;
reg signC;
reg signed [15:0] scaledCos;
reg signed [15:0] scaledSin;
reg [13:0] shiftedC;
reg [13:0] shiftedS;
reg [13:0] shiftedCosTemp;
reg [13:0] shiftedSinTemp;


always @(posedge clk or posedge reset) begin
    if (start) begin
        start <= 0;
    end
    if (reset) begin
        
        // Clear framebuffer
        for (i = 0; i < 64; i = i + 1) begin
            /* verilator lint_off WIDTH */
            row = framebuffer[i];
            row = 0;
            framebuffer[i] = row;
            /* verilator lint_on WIDTH */
            //$display("%b", framebuffer[i]);
            
        end
        start = 0;
        refreshCycleRunning = 1'b0;
        cordicRunning = 1'b0;
        //cordDone = 1'b0;
        cordicStart = 1'b0;
        
        done = 1;
        restartInhibit = 0;
        state = DRAW_HRS;
        pixel_bw_reg <= 0;

    end else begin
        if (!slow_clk) begin
            restartInhibit = 1'b0;
            //$display("inhibit deactivated");
        end
        if (slow_clk && done && !restartInhibit) begin
            start = 1'b1;
            restartInhibit = 1'b1;
            //$display("start");
        end

        if (start) begin
            
            done = 0;
            if (!refreshCycleRunning) begin
                for (i = 0; i < 64; i = i + 1) begin
                    /* verilator lint_off WIDTH */
                    row = framebuffer[i];
                    row = 0;
                    framebuffer[i] = row;
                    /* verilator lint_on WIDTH */
                    //$display("%b", framebuffer[i]);
                end
                refreshCycleRunning = 1'b1;
            end
        end
        
        if (refreshCycleRunning) begin
            //$display("test");
            case(state) 
                DRAW_HRS: begin
                    if (!cordicRunning) begin
                        //$display("entered");
                        /* verilator lint_off WIDTH */
                        currAngle = hour_angle;
                        /* verilator lint_on WIDTH */
                        //$display("hrsAng = %f", currAngle);
                        cordicStart = 1'b1;
                        cordicRunning = 1'b1;
                    end else if (cordicRunning) begin
                        cordicStart = 1'b0;
                        if (cordDone) begin
                            //map_clockhand(sinW, cosW, HOUR_LEN);
                            /* verilator lint_off WIDTH */
    	                    signS = sinW >>> 14;
                            signC = cosW >>> 14;

                            shiftedC = cosW;
                            shiftedS = sinW;
                            
                            for (j = 1; j <= 23; j = j + 2) begin
                                if (signS == 0) begin
                                    scaledSin = ((shiftedS * j) / 16384);
                                end else begin
                                    shiftedSinTemp = 16384 - shiftedS;
                                    scaledSin = -((shiftedSinTemp * j) / 16384);
                                end
                                if (signC == 0) begin
                                    scaledCos = ((shiftedC * j) / 16384);
                                end else begin
                                    shiftedCosTemp = 16384 - shiftedC;
                                    scaledCos = -((shiftedCosTemp * j) / 16384);
                                end
                                //scaledCos = 0;
                                //scaledSin = 0;
                                row = framebuffer[(63-(32 + scaledCos))];
                                row[(63 - (32 + scaledSin))] = 1'b1;
                                framebuffer[(63-(32 + scaledCos))] = row;
                            end
                            /* verilator lint_on WIDTH */
                            if (j == 23) begin
                                //cordicRunning = 1'b0;
                                //state = DRAW_MINS;
                                cordicRunning = 1'b0;
                                refreshCycleRunning = 1'b0;
                                done = 1;
                                state = DRAW_HRS;
                            end
                        end
                    end
                end
        //         DRAW_MINS: begin
        //             if (!cordicRunning) begin
        //                 /* verilator lint_off WIDTH */
        //                 currAngle = minute_angle;
        //                 /* verilator lint_on WIDTH */
        //                 //$display("minAng = %f", currAngle);
        //                 cordicStart = 1'b1;
        //                 cordicRunning = 1'b1;
        //             end else if (cordicRunning) begin
        //                 cordicStart = 1'b0;
        //                 if (cordDone) begin
        //                     //map_clockhand(sinW, cosW, MINUTE_LEN);
        //                     /* verilator lint_off WIDTH */
        //                     signS = sinW >>> 14;
        //                     signC = cosW >>> 14;

        //                     shiftedC = cosW;
        //                     shiftedS = sinW;
        //                     //j =1;
        //                     for (k = 1; k <= 31; k = k + 2) begin
        //                         if (signS == 0) begin
        //                             scaledSin = ((shiftedS * k) / 16384);
        //                         end else begin
        //                             shiftedSinTemp = 16384 - shiftedS;
        //                             scaledSin = -((shiftedSinTemp * k) / 16384);
        //                         end
        //                         if (signC == 0) begin
        //                             scaledCos = ((shiftedC * k) / 16384);
        //                         end else begin
        //                             shiftedCosTemp = 16384 - shiftedC;
        //                             scaledCos = -((shiftedCosTemp * k) / 16384);
        //                         end
        //                         //scaledCos = 0;
        //                         //scaledSin = 0;
        //                         row = framebuffer[(63-(32 + scaledCos))];
        //                         row[(63 - (32 + scaledSin))] = 1'b1;
        //                         framebuffer[(63-(32 + scaledCos))] = row;
        //                     end
        //                     /* verilator lint_on WIDTH */
        //                     if (k == 31) begin
        //                         cordicRunning = 1'b0;
        //                         state = DRAW_SECS;
        //                     end
        //                 end
        //             end
        //         end
        //         DRAW_SECS: begin
        //             if (!cordicRunning) begin
        //                 /* verilator lint_off WIDTH */
        //                 currAngle = second_angle;
        //                 /* verilator lint_on WIDTH */
        //                 //$display("secAng = %f", currAngle);
        //                 cordicStart = 1'b1;
        //                 cordicRunning = 1'b1;
        //             end else if (cordicRunning) begin
        //                 cordicStart = 1'b0;
        //                 if (cordDone) begin
        //                     //map_clockhand(sinW, cosW, SEC_LEN);
        //                     /* verilator lint_off WIDTH */
        //                     signS = sinW >>> 14;
        //                     signC = cosW >>> 14;

        //                     shiftedC = cosW;
        //                     shiftedS = sinW;
                            
        //                     for (l = 1; l <= 27; l = l + 2) begin
        //                         if (signS == 0) begin
        //                             scaledSin = ((shiftedS * l) / 16384);
        //                         end else begin
        //                             shiftedSinTemp = 16384 - shiftedS;
        //                             scaledSin = -((shiftedSinTemp * l) / 16384);
        //                         end
        //                         if (signC == 0) begin
        //                             scaledCos = ((shiftedC * l) / 16384);
        //                         end else begin
        //                             shiftedCosTemp = 16384 - shiftedC;
        //                             scaledCos = -((shiftedCosTemp * l) / 16384);
        //                         end

        //                         row = framebuffer[(63-(32 + scaledCos))];
        //                         row[(63 - (32 + scaledSin))] = 1'b1;
        //                         framebuffer[(63-(32 + scaledCos))] = row;
        //                     end
        //                     /* verilator lint_on WIDTH */
        //                     if (l == 27) begin
        //                         cordicRunning = 1'b0;
        //                         state = DRAW_ALARM;
        //                     end
        //                 end
        //             end
        //         end
        //         DRAW_ALARM: begin
        //             if (!cordicRunning) begin
        //                 /* verilator lint_off WIDTH */
        //                 currAngle = alarm_angle;
        //                 /* verilator lint_on WIDTH */
        //                 //$display("alAng = %f", currAngle);
        //                 cordicStart = 1'b1;
        //                 cordicRunning = 1'b1;
        //             end else if (cordicRunning) begin
        //                 cordicStart = 1'b0;
        //                 if (cordDone) begin
        //                     //map_clockhand(sinW, cosW, ALARM_LEN);
        //                     /* verilator lint_off WIDTH */
        //                     signS = sinW >>> 14;
        //                     signC = cosW >>> 14;

        //                     shiftedC = cosW;
        //                     shiftedS = sinW;
                            
        //                     for (m = 1; m <= 17; m = m + 2) begin
        //                         if (signS == 0) begin
        //                             scaledSin = ((shiftedS * m) / 16384);
        //                         end else begin
        //                             shiftedSinTemp = 16384 - shiftedS;
        //                             scaledSin = -((shiftedSinTemp * m) / 16384);
        //                         end
        //                         if (signC == 0) begin
        //                             scaledCos = ((shiftedC * m) / 16384);
        //                         end else begin
        //                             shiftedCosTemp = 16384 - shiftedC;
        //                             scaledCos = -((shiftedCosTemp * m) / 16384);
        //                         end

        //                         row = framebuffer[(63-(32 + scaledCos))];
        //                         row[(63 - (32 + scaledSin))] = 1'b1;
        //                         framebuffer[(63-(32 + scaledCos))] = row;
        //                     end
        //                     /* verilator lint_on WIDTH */
        //                     if (m == 17) begin
        //                         cordicRunning = 1'b0;
        //                         refreshCycleRunning = 1'b0;
        //                         done = 1;
        //                         state = DRAW_HRS;
        //                         //$display("Done!");
        //                     end
                            
        //                 end
        //             end
        //         end
                default: begin
                    state = DRAW_HRS;
                end
            endcase  
        end
        if (in_display_area && done) begin
            dispRow = framebuffer[fb_y];
            pixel_bw_reg <= dispRow[63-fb_x];
            //$display("drawing");
        end
        else begin
            pixel_bw_reg <= 1'b0; 
        end
    end
end
    

/* verilator lint_on BLKSEQ */
endmodule
