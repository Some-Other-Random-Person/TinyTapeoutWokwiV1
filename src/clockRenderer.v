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

// reg cordicStart;
// reg cordicRunning;
// wire cordDone;
reg [6:0] i, j, k, l, m;
// reg refreshCycleRunning;
reg done;
// reg start;
reg restartInhibit;
reg run;

reg [15:0] currAngle;
//wire [15:0] sinW;
//wire [15:0] cosW;

reg pixel_bw_reg;
assign pixel_bw = pixel_bw_reg ? 1'b1 : 1'b0;

//cordic_sin_cos cordicModule (.clk(clk), .reset(reset), .start(cordicStart), .i_angle(currAngle), .sine_output(sinW), .cosine_output(cosW), .done(cordDone));

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

reg signed [7:0] sine_table [0:90];
reg signed [7:0] cos_table  [0:90];
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

// reg signS;
// reg signC;
reg signed [15:0] scaledCos;
reg signed [15:0] scaledSin;
// reg [13:0] shiftedC;
// reg [13:0] shiftedS;
// reg [13:0] shiftedCosTemp;
// reg [13:0] shiftedSinTemp;

//wire [8:0] angle; // 0–359 input
reg [1:0] quadrant;
reg [6:0] idx; // index into 0–90 table

reg signed [7:0] sine_val;
reg signed [7:0] cos_val;

// always @(posedge clk or posedge reset) begin
//     if (start) begin
//         start = 0;
//     end
//     if (reset) begin
        
//         // Clear framebuffer
//         for (i = 0; i < 64; i = i + 1) begin
//             /* verilator lint_off WIDTH */
//             row = framebuffer[i];
//             row = 0;
//             framebuffer[i] = row;
//             /* verilator lint_on WIDTH */
//             //$display("%b", framebuffer[i]);
            
//         end
//         start = 0;
//         refreshCycleRunning = 1'b0;
//         cordicRunning = 1'b0;
//         //cordDone = 1'b0;
//         cordicStart = 1'b0;
        
//         done = 1;
//         restartInhibit = 0;
//         state = DRAW_HRS;
//         pixel_bw_reg <= 0;

//     end else begin
//         if (!slow_clk) begin
//             restartInhibit = 1'b0;
//             //$display("inhibit deactivated");
//         end
//         if (slow_clk && done && !restartInhibit) begin
//             start = 1'b1;
//             restartInhibit = 1'b1;
//             //$display("start");
//         end

//         if (start) begin
            
//             done = 0;
//             if (!refreshCycleRunning) begin
//                 for (i = 0; i < 64; i = i + 1) begin
//                     /* verilator lint_off WIDTH */
//                     row = framebuffer[i];
//                     row = 0;
//                     framebuffer[i] = row;
//                     /* verilator lint_on WIDTH */
//                     //$display("%b", framebuffer[i]);
//                 end
//                 refreshCycleRunning = 1'b1;
//             end
//         end
        
//         if (refreshCycleRunning) begin
//             //$display("test");
//             case(state) 
//                 DRAW_HRS: begin
//                     if (!cordicRunning) begin
//                         //$display("entered");
//                         /* verilator lint_off WIDTH */
//                         currAngle = hour_angle;
//                         /* verilator lint_on WIDTH */
//                         //$display("hrsAng = %f", currAngle);
//                         cordicStart = 1'b1;
//                         cordicRunning = 1'b1;
//                     end else if (cordicRunning) begin
//                         cordicStart = 1'b0;
//                         if (cordDone) begin
//                             //map_clockhand(sinW, cosW, HOUR_LEN);
//                             /* verilator lint_off WIDTH */
//     	                    signS = sinW >>> 14;
//                             signC = cosW >>> 14;

//                             shiftedC = cosW;
//                             shiftedS = sinW;
                            
//                             for (j = 1; j <= 23; j = j + 2) begin
//                                 if (signS == 0) begin
//                                     scaledSin = ((shiftedS * j) / 16384);
//                                 end else begin
//                                     shiftedSinTemp = 16384 - shiftedS;
//                                     scaledSin = -((shiftedSinTemp * j) / 16384);
//                                 end
//                                 if (signC == 0) begin
//                                     scaledCos = ((shiftedC * j) / 16384);
//                                 end else begin
//                                     shiftedCosTemp = 16384 - shiftedC;
//                                     scaledCos = -((shiftedCosTemp * j) / 16384);
//                                 end
//                                 //scaledCos = 0;
//                                 //scaledSin = 0;
//                                 row = framebuffer[(63-(32 + scaledCos))];
//                                 row[(63 - (32 + scaledSin))] = 1'b1;
//                                 framebuffer[(63-(32 + scaledCos))] = row;
//                             end
//                             /* verilator lint_on WIDTH */
//                             if (j == 23) begin
//                                 //cordicRunning = 1'b0;
//                                 //state = DRAW_MINS;
//                                 cordicRunning = 1'b0;
//                                 refreshCycleRunning = 1'b0;
//                                 done = 1;
//                                 state = DRAW_HRS;
//                             end
//                         end
//                     end
//                 end
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
        //         default: begin
        //             state = DRAW_HRS;
        //         end
        //     endcase  
        // end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        

        sine_table[0] = 8'sd0; cos_table[0] = 8'sd127;
        sine_table[1] = 8'sd2; cos_table[1] = 8'sd127;
        sine_table[2] = 8'sd4; cos_table[2] = 8'sd127;
        sine_table[3] = 8'sd7; cos_table[3] = 8'sd127;
        sine_table[4] = 8'sd9; cos_table[4] = 8'sd127;
        sine_table[5] = 8'sd11; cos_table[5] = 8'sd127;
        sine_table[6] = 8'sd13; cos_table[6] = 8'sd126;
        sine_table[7] = 8'sd15; cos_table[7] = 8'sd126;
        sine_table[8] = 8'sd18; cos_table[8] = 8'sd126;
        sine_table[9] = 8'sd20; cos_table[9] = 8'sd125;
        sine_table[10] = 8'sd22; cos_table[10] = 8'sd125;
        sine_table[11] = 8'sd24; cos_table[11] = 8'sd125;
        sine_table[12] = 8'sd26; cos_table[12] = 8'sd124;
        sine_table[13] = 8'sd29; cos_table[13] = 8'sd124;
        sine_table[14] = 8'sd31; cos_table[14] = 8'sd123;
        sine_table[15] = 8'sd33; cos_table[15] = 8'sd123;
        sine_table[16] = 8'sd35; cos_table[16] = 8'sd122;
        sine_table[17] = 8'sd37; cos_table[17] = 8'sd121;
        sine_table[18] = 8'sd39; cos_table[18] = 8'sd121;
        sine_table[19] = 8'sd41; cos_table[19] = 8'sd120;
        sine_table[20] = 8'sd43; cos_table[20] = 8'sd119;
        sine_table[21] = 8'sd46; cos_table[21] = 8'sd119;
        sine_table[22] = 8'sd48; cos_table[22] = 8'sd118;
        sine_table[23] = 8'sd50; cos_table[23] = 8'sd117;
        sine_table[24] = 8'sd52; cos_table[24] = 8'sd116;
        sine_table[25] = 8'sd54; cos_table[25] = 8'sd115;
        sine_table[26] = 8'sd56; cos_table[26] = 8'sd114;
        sine_table[27] = 8'sd58; cos_table[27] = 8'sd113;
        sine_table[28] = 8'sd60; cos_table[28] = 8'sd112;
        sine_table[29] = 8'sd62; cos_table[29] = 8'sd111;
        sine_table[30] = 8'sd63; cos_table[30] = 8'sd110;
        sine_table[31] = 8'sd65; cos_table[31] = 8'sd109;
        sine_table[32] = 8'sd67; cos_table[32] = 8'sd108;
        sine_table[33] = 8'sd69; cos_table[33] = 8'sd107;
        sine_table[34] = 8'sd71; cos_table[34] = 8'sd105;
        sine_table[35] = 8'sd73; cos_table[35] = 8'sd104;
        sine_table[36] = 8'sd75; cos_table[36] = 8'sd103;
        sine_table[37] = 8'sd76; cos_table[37] = 8'sd101;
        sine_table[38] = 8'sd78; cos_table[38] = 8'sd100;
        sine_table[39] = 8'sd80; cos_table[39] = 8'sd99;
        sine_table[40] = 8'sd82; cos_table[40] = 8'sd97;
        sine_table[41] = 8'sd83; cos_table[41] = 8'sd96;
        sine_table[42] = 8'sd85; cos_table[42] = 8'sd94;
        sine_table[43] = 8'sd87; cos_table[43] = 8'sd93;
        sine_table[44] = 8'sd88; cos_table[44] = 8'sd91;
        sine_table[45] = 8'sd90; cos_table[45] = 8'sd90;
        sine_table[46] = 8'sd91; cos_table[46] = 8'sd88;
        sine_table[47] = 8'sd93; cos_table[47] = 8'sd87;
        sine_table[48] = 8'sd94; cos_table[48] = 8'sd85;
        sine_table[49] = 8'sd96; cos_table[49] = 8'sd83;
        sine_table[50] = 8'sd97; cos_table[50] = 8'sd82;
        sine_table[51] = 8'sd99; cos_table[51] = 8'sd80;
        sine_table[52] = 8'sd100; cos_table[52] = 8'sd78;
        sine_table[53] = 8'sd101; cos_table[53] = 8'sd76;
        sine_table[54] = 8'sd103; cos_table[54] = 8'sd75;
        sine_table[55] = 8'sd104; cos_table[55] = 8'sd73;
        sine_table[56] = 8'sd105; cos_table[56] = 8'sd71;
        sine_table[57] = 8'sd107; cos_table[57] = 8'sd69;
        sine_table[58] = 8'sd108; cos_table[58] = 8'sd67;
        sine_table[59] = 8'sd109; cos_table[59] = 8'sd65;
        sine_table[60] = 8'sd110; cos_table[60] = 8'sd64;
        sine_table[61] = 8'sd111; cos_table[61] = 8'sd62;
        sine_table[62] = 8'sd112; cos_table[62] = 8'sd60;
        sine_table[63] = 8'sd113; cos_table[63] = 8'sd58;
        sine_table[64] = 8'sd114; cos_table[64] = 8'sd56;
        sine_table[65] = 8'sd115; cos_table[65] = 8'sd54;
        sine_table[66] = 8'sd116; cos_table[66] = 8'sd52;
        sine_table[67] = 8'sd117; cos_table[67] = 8'sd50;
        sine_table[68] = 8'sd118; cos_table[68] = 8'sd48;
        sine_table[69] = 8'sd119; cos_table[69] = 8'sd46;
        sine_table[70] = 8'sd119; cos_table[70] = 8'sd43;
        sine_table[71] = 8'sd120; cos_table[71] = 8'sd41;
        sine_table[72] = 8'sd121; cos_table[72] = 8'sd39;
        sine_table[73] = 8'sd121; cos_table[73] = 8'sd37;
        sine_table[74] = 8'sd122; cos_table[74] = 8'sd35;
        sine_table[75] = 8'sd123; cos_table[75] = 8'sd33;
        sine_table[76] = 8'sd123; cos_table[76] = 8'sd31;
        sine_table[77] = 8'sd124; cos_table[77] = 8'sd29;
        sine_table[78] = 8'sd124; cos_table[78] = 8'sd26;
        sine_table[79] = 8'sd125; cos_table[79] = 8'sd24;
        sine_table[80] = 8'sd125; cos_table[80] = 8'sd22;
        sine_table[81] = 8'sd125; cos_table[81] = 8'sd20;
        sine_table[82] = 8'sd126; cos_table[82] = 8'sd18;
        sine_table[83] = 8'sd126; cos_table[83] = 8'sd15;
        sine_table[84] = 8'sd126; cos_table[84] = 8'sd13;
        sine_table[85] = 8'sd127; cos_table[85] = 8'sd11;
        sine_table[86] = 8'sd127; cos_table[86] = 8'sd9;
        sine_table[87] = 8'sd127; cos_table[87] = 8'sd7;
        sine_table[88] = 8'sd127; cos_table[88] = 8'sd4;
        sine_table[89] = 8'sd127; cos_table[89] = 8'sd2;
        sine_table[90] = 8'sd127; cos_table[90] = 8'sd0;

        // Clear framebuffer
        for (i = 0; i < 64; i = i + 1) begin
            /* verilator lint_off WIDTH */
            row = framebuffer[i];
            row = 0;
            framebuffer[i] = row;
            /* verilator lint_on WIDTH */
            //$display("%b", framebuffer[i]);
            
        end
        restartInhibit = 0;
        done = 1;
        run = 0;

    end else begin
        if (slow_clk && done && !restartInhibit) begin
            done = 0;
            restartInhibit = 1;
            run = 1;
        end else if (!slow_clk) begin
            restartInhibit = 0;
        end
        if (run) begin
            case(state) 
                DRAW_HRS: begin
                    done = 0;
                    currAngle = hour_angle;

                    quadrant = currAngle / 90;
                    idx      = currAngle % 90;

                    case (quadrant)
                        2'b00: begin // 0–89°
                            sine_val = sine_table[idx];
                            cos_val  = cos_table[idx];
                        end
                        2'b01: begin // 90–179°
                            sine_val = sine_table[90 - idx];
                            cos_val  = -cos_table[90 - idx];
                        end
                        2'b10: begin // 180–269°
                            sine_val = -sine_table[idx];
                            cos_val  = -cos_table[idx];
                        end
                        2'b11: begin // 270–359°
                            sine_val = -sine_table[90 - idx];
                            cos_val  = cos_table[90 - idx];
                        end
                    endcase
                    for (j = 1; j <= 23; j = j + 2) begin
                        
                        scaledSin = (sine_val * j) / 127;
                        scaledCos  = (cos_val  * j) / 127;

                        row = framebuffer[(63-(32 + scaledCos))];
                        row[(63 - (32 + scaledSin))] = 1'b1;
                        framebuffer[(63-(32 + scaledCos))] = row;
                    end
                    if (j == 23) begin
                        state = DRAW_MINS;
                    end
                end
                DRAW_MINS: begin
                    currAngle = minute_angle;

                    quadrant = currAngle / 90;
                    idx      = currAngle % 90;

                    case (quadrant)
                        2'b00: begin // 0–89°
                            sine_val = sine_table[idx];
                            cos_val  = cos_table[idx];
                        end
                        2'b01: begin // 90–179°
                            sine_val = sine_table[90 - idx];
                            cos_val  = -cos_table[90 - idx];
                        end
                        2'b10: begin // 180–269°
                            sine_val = -sine_table[idx];
                            cos_val  = -cos_table[idx];
                        end
                        2'b11: begin // 270–359°
                            sine_val = -sine_table[90 - idx];
                            cos_val  = cos_table[90 - idx];
                        end
                    endcase
                    for (k = 1; k <= 31; k = k + 2) begin
                        
                        scaledSin = (sine_val * k) / 127;
                        scaledCos  = (cos_val  * k) / 127;

                        row = framebuffer[(63-(32 + scaledCos))];
                        row[(63 - (32 + scaledSin))] = 1'b1;
                        framebuffer[(63-(32 + scaledCos))] = row;
                    end
                    if (k == 31) begin
                        state = DRAW_SECS;
                    end
                end
                DRAW_SECS: begin
                    currAngle = second_angle;

                    quadrant = currAngle / 90;
                    idx      = currAngle % 90;

                    case (quadrant)
                        2'b00: begin // 0–89°
                            sine_val = sine_table[idx];
                            cos_val  = cos_table[idx];
                        end
                        2'b01: begin // 90–179°
                            sine_val = sine_table[90 - idx];
                            cos_val  = -cos_table[90 - idx];
                        end
                        2'b10: begin // 180–269°
                            sine_val = -sine_table[idx];
                            cos_val  = -cos_table[idx];
                        end
                        2'b11: begin // 270–359°
                            sine_val = -sine_table[90 - idx];
                            cos_val  = cos_table[90 - idx];
                        end
                    endcase
                    for (l = 1; l <= 27; l = l + 2) begin
                        
                        scaledSin = (sine_val * l) / 127;
                        scaledCos  = (cos_val  * l) / 127;

                        row = framebuffer[(63-(32 + scaledCos))];
                        row[(63 - (32 + scaledSin))] = 1'b1;
                        framebuffer[(63-(32 + scaledCos))] = row;
                    end
                    if (l == 27) begin
                        state = DRAW_ALARM;
                    end
                end
                DRAW_ALARM: begin
                    currAngle = alarm_angle;

                    quadrant = currAngle / 90;
                    idx      = currAngle % 90;

                    case (quadrant)
                        2'b00: begin // 0–89°
                            sine_val = sine_table[idx];
                            cos_val  = cos_table[idx];
                        end
                        2'b01: begin // 90–179°
                            sine_val = sine_table[90 - idx];
                            cos_val  = -cos_table[90 - idx];
                        end
                        2'b10: begin // 180–269°
                            sine_val = -sine_table[idx];
                            cos_val  = -cos_table[idx];
                        end
                        2'b11: begin // 270–359°
                            sine_val = -sine_table[90 - idx];
                            cos_val  = cos_table[90 - idx];
                        end
                    endcase
                    for (m = 1; m <= 17; m = m + 2) begin
                        
                        scaledSin = (sine_val * l) / 127;
                        scaledCos  = (cos_val  * l) / 127;

                        row = framebuffer[(63-(32 + scaledCos))];
                        row[(63 - (32 + scaledSin))] = 1'b1;
                        framebuffer[(63-(32 + scaledCos))] = row;
                    end
                    if (m == 17) begin
                        state = DRAW_HRS;
                    end
                end
                default: begin
                    state = DRAW_HRS;
                    done = 1;
                    run = 0;
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
