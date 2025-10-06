module counter (clk_i,
    rst_i,
    counter_val_o);
 input clk_i;
 input rst_i;
 output [7:0] counter_val_o;

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
 wire VPWR;
 wire VGND;

 sky130_fd_sc_hd__and3_2 _19_ (.A(counter_val_o[0]),
    .B(counter_val_o[1]),
    .C(counter_val_o[2]),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_08_));
 sky130_fd_sc_hd__and4_2 _20_ (.A(counter_val_o[0]),
    .B(counter_val_o[1]),
    .C(counter_val_o[2]),
    .D(counter_val_o[3]),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_09_));
 sky130_fd_sc_hd__and3_2 _21_ (.A(counter_val_o[4]),
    .B(counter_val_o[5]),
    .C(_09_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_10_));
 sky130_fd_sc_hd__a21oi_2 _22_ (.A1(counter_val_o[6]),
    .A2(_10_),
    .B1(rst_i),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_11_));
 sky130_fd_sc_hd__o21a_2 _23_ (.A1(counter_val_o[6]),
    .A2(_10_),
    .B1(_11_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_00_));
 sky130_fd_sc_hd__a21oi_2 _24_ (.A1(counter_val_o[6]),
    .A2(_10_),
    .B1(counter_val_o[7]),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_12_));
 sky130_fd_sc_hd__a31o_2 _25_ (.A1(counter_val_o[6]),
    .A2(counter_val_o[7]),
    .A3(_10_),
    .B1(rst_i),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_13_));
 sky130_fd_sc_hd__nor2_2 _26_ (.A(_12_),
    .B(_13_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_01_));
 sky130_fd_sc_hd__nor2_2 _27_ (.A(counter_val_o[0]),
    .B(rst_i),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_02_));
 sky130_fd_sc_hd__a21oi_2 _28_ (.A1(counter_val_o[0]),
    .A2(counter_val_o[1]),
    .B1(rst_i),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_14_));
 sky130_fd_sc_hd__o21a_2 _29_ (.A1(counter_val_o[0]),
    .A2(counter_val_o[1]),
    .B1(_14_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_03_));
 sky130_fd_sc_hd__a21oi_2 _30_ (.A1(counter_val_o[0]),
    .A2(counter_val_o[1]),
    .B1(counter_val_o[2]),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_15_));
 sky130_fd_sc_hd__nor3_2 _31_ (.A(rst_i),
    .B(_08_),
    .C(_15_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_04_));
 sky130_fd_sc_hd__nor2_2 _32_ (.A(rst_i),
    .B(_09_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_16_));
 sky130_fd_sc_hd__o21a_2 _33_ (.A1(counter_val_o[3]),
    .A2(_08_),
    .B1(_16_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_05_));
 sky130_fd_sc_hd__a21oi_2 _34_ (.A1(counter_val_o[4]),
    .A2(_09_),
    .B1(rst_i),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_17_));
 sky130_fd_sc_hd__o21a_2 _35_ (.A1(counter_val_o[4]),
    .A2(_09_),
    .B1(_17_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .X(_06_));
 sky130_fd_sc_hd__a21oi_2 _36_ (.A1(counter_val_o[4]),
    .A2(_09_),
    .B1(counter_val_o[5]),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_18_));
 sky130_fd_sc_hd__nor3_2 _37_ (.A(rst_i),
    .B(_10_),
    .C(_18_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Y(_07_));
 sky130_fd_sc_hd__dfxtp_2 _38_ (.CLK(clk_i),
    .D(_00_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[6]));
 sky130_fd_sc_hd__dfxtp_2 _39_ (.CLK(clk_i),
    .D(_01_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[7]));
 sky130_fd_sc_hd__dfxtp_2 _40_ (.CLK(clk_i),
    .D(_02_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[0]));
 sky130_fd_sc_hd__dfxtp_2 _41_ (.CLK(clk_i),
    .D(_03_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[1]));
 sky130_fd_sc_hd__dfxtp_2 _42_ (.CLK(clk_i),
    .D(_04_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[2]));
 sky130_fd_sc_hd__dfxtp_2 _43_ (.CLK(clk_i),
    .D(_05_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[3]));
 sky130_fd_sc_hd__dfxtp_2 _44_ (.CLK(clk_i),
    .D(_06_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[4]));
 sky130_fd_sc_hd__dfxtp_2 _45_ (.CLK(clk_i),
    .D(_07_),
    .VGND(VGND),
    .VNB(VGND),
    .VPB(VPWR),
    .VPWR(VPWR),
    .Q(counter_val_o[5]));
endmodule
