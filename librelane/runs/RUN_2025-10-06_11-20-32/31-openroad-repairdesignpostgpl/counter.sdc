###############################################################################
# Created by write_sdc
###############################################################################
current_design counter
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_i -period 20.0000 [get_ports {clk_i}]
set_clock_transition 0.1500 [get_clocks {clk_i}]
set_clock_uncertainty 0.2500 clk_i
set_input_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {rst_i}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[0]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[1]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[2]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[3]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[4]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[5]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[6]}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {counter_val_o[7]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {counter_val_o[7]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[6]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[5]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[4]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[3]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[2]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[1]}]
set_load -pin_load 0.0334 [get_ports {counter_val_o[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_i}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
