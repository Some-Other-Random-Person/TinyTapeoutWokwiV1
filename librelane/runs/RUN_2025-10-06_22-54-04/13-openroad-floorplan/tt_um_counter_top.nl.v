module tt_um_counter_top (clk,
    ena,
    rst_n,
    ui_in,
    uio_in,
    uio_oe,
    uio_out,
    uo_out);
 input clk;
 input ena;
 input rst_n;
 input [7:0] ui_in;
 input [7:0] uio_in;
 output [7:0] uio_oe;
 output [7:0] uio_out;
 output [7:0] uo_out;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire _11_;
 wire _12_;
 wire _13_;
 wire _14_;
 wire _15_;
 wire _16_;
 wire _17_;
 wire _18_;

 sky130_fd_sc_hd__nand3_2 _19_ (.A(uo_out[0]),
    .B(uo_out[1]),
    .C(uo_out[2]),
    .Y(_08_));
 sky130_fd_sc_hd__a31o_2 _20_ (.A1(uo_out[0]),
    .A2(uo_out[1]),
    .A3(uo_out[2]),
    .B1(uo_out[3]),
    .X(_09_));
 sky130_fd_sc_hd__and4_2 _21_ (.A(uo_out[0]),
    .B(uo_out[1]),
    .C(uo_out[2]),
    .D(uo_out[3]),
    .X(_10_));
 sky130_fd_sc_hd__and3b_2 _22_ (.A_N(_10_),
    .B(rst_n),
    .C(_09_),
    .X(_00_));
 sky130_fd_sc_hd__o21ai_2 _23_ (.A1(uo_out[4]),
    .A2(_10_),
    .B1(rst_n),
    .Y(_11_));
 sky130_fd_sc_hd__a21oi_2 _24_ (.A1(uo_out[4]),
    .A2(_10_),
    .B1(_11_),
    .Y(_01_));
 sky130_fd_sc_hd__a21o_2 _25_ (.A1(uo_out[4]),
    .A2(_10_),
    .B1(uo_out[5]),
    .X(_12_));
 sky130_fd_sc_hd__and3_2 _26_ (.A(uo_out[4]),
    .B(uo_out[5]),
    .C(_10_),
    .X(_13_));
 sky130_fd_sc_hd__and3b_2 _27_ (.A_N(_13_),
    .B(rst_n),
    .C(_12_),
    .X(_02_));
 sky130_fd_sc_hd__or2_2 _28_ (.A(uo_out[6]),
    .B(_13_),
    .X(_14_));
 sky130_fd_sc_hd__and4_2 _29_ (.A(uo_out[4]),
    .B(uo_out[5]),
    .C(uo_out[6]),
    .D(_10_),
    .X(_15_));
 sky130_fd_sc_hd__and3b_2 _30_ (.A_N(_15_),
    .B(rst_n),
    .C(_14_),
    .X(_03_));
 sky130_fd_sc_hd__o21ai_2 _31_ (.A1(uo_out[7]),
    .A2(_15_),
    .B1(rst_n),
    .Y(_16_));
 sky130_fd_sc_hd__a21oi_2 _32_ (.A1(uo_out[7]),
    .A2(_15_),
    .B1(_16_),
    .Y(_04_));
 sky130_fd_sc_hd__and2b_2 _33_ (.A_N(uo_out[0]),
    .B(rst_n),
    .X(_05_));
 sky130_fd_sc_hd__o21ai_2 _34_ (.A1(uo_out[0]),
    .A2(uo_out[1]),
    .B1(rst_n),
    .Y(_17_));
 sky130_fd_sc_hd__a21oi_2 _35_ (.A1(uo_out[0]),
    .A2(uo_out[1]),
    .B1(_17_),
    .Y(_06_));
 sky130_fd_sc_hd__a21o_2 _36_ (.A1(uo_out[0]),
    .A2(uo_out[1]),
    .B1(uo_out[2]),
    .X(_18_));
 sky130_fd_sc_hd__and3_2 _37_ (.A(rst_n),
    .B(_08_),
    .C(_18_),
    .X(_07_));
 sky130_fd_sc_hd__dfxtp_2 _38_ (.CLK(clk),
    .D(_00_),
    .Q(uo_out[3]));
 sky130_fd_sc_hd__dfxtp_2 _39_ (.CLK(clk),
    .D(_01_),
    .Q(uo_out[4]));
 sky130_fd_sc_hd__dfxtp_2 _40_ (.CLK(clk),
    .D(_02_),
    .Q(uo_out[5]));
 sky130_fd_sc_hd__dfxtp_2 _41_ (.CLK(clk),
    .D(_03_),
    .Q(uo_out[6]));
 sky130_fd_sc_hd__dfxtp_2 _42_ (.CLK(clk),
    .D(_04_),
    .Q(uo_out[7]));
 sky130_fd_sc_hd__dfxtp_2 _43_ (.CLK(clk),
    .D(_05_),
    .Q(uo_out[0]));
 sky130_fd_sc_hd__dfxtp_2 _44_ (.CLK(clk),
    .D(_06_),
    .Q(uo_out[1]));
 sky130_fd_sc_hd__dfxtp_2 _45_ (.CLK(clk),
    .D(_07_),
    .Q(uo_out[2]));
 sky130_fd_sc_hd__conb_1 _46_ (.LO(uio_oe[0]));
 sky130_fd_sc_hd__conb_1 _47_ (.LO(uio_oe[1]));
 sky130_fd_sc_hd__conb_1 _48_ (.LO(uio_oe[2]));
 sky130_fd_sc_hd__conb_1 _49_ (.LO(uio_oe[3]));
 sky130_fd_sc_hd__conb_1 _50_ (.LO(uio_oe[4]));
 sky130_fd_sc_hd__conb_1 _51_ (.LO(uio_oe[5]));
 sky130_fd_sc_hd__conb_1 _52_ (.LO(uio_oe[6]));
 sky130_fd_sc_hd__conb_1 _53_ (.LO(uio_oe[7]));
 sky130_fd_sc_hd__conb_1 _54_ (.LO(uio_out[0]));
 sky130_fd_sc_hd__conb_1 _55_ (.LO(uio_out[1]));
 sky130_fd_sc_hd__conb_1 _56_ (.LO(uio_out[2]));
 sky130_fd_sc_hd__conb_1 _57_ (.LO(uio_out[3]));
 sky130_fd_sc_hd__conb_1 _58_ (.LO(uio_out[4]));
 sky130_fd_sc_hd__conb_1 _59_ (.LO(uio_out[5]));
 sky130_fd_sc_hd__conb_1 _60_ (.LO(uio_out[6]));
 sky130_fd_sc_hd__conb_1 _61_ (.LO(uio_out[7]));
endmodule
