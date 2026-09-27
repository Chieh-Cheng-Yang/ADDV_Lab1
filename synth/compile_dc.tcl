#/**************************************************/
#/* Compile Script for Synopsys                    */
#/*                                                */
#/* dc_shell-t -f compile_dc.tcl                   */
#/*                                                */
#/* OSU FreePDK 45nm                               */
#/**************************************************/

#/* All verilog files, separated by spaces         */
set my_verilog_files [glob ../RTL_noTB/*.sv]

#/* Top-level Module                               */
set my_toplevel   FIFO_TOP

#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 1000

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set OSU_FREEPDK [format "%s%s"  [getenv "PDK_DIR"] "/osu_soc/lib/files"]
set search_path [concat  $search_path $OSU_FREEPDK]
set alib_library_analysis_path $OSU_FREEPDK

set link_library [set target_library [concat  [list gscl45nm.db] [list dw_foundation.sldb]]]
set target_library "gscl45nm.db"
define_design_lib WORK -path ./WORK
set verilogout_show_unconnected_pins "true"
set_ultra_optimization true
set_ultra_optimization -force

analyze -format sverilog $my_verilog_files

elaborate $my_toplevel

current_design $my_toplevel

link
uniquify

#set my_period [expr 1000.0 / $my_clk_freq_MHz]

#set my_period_w 0.7
#set my_period_r 0.7
set my_period_w 10
set my_period_r 14

create_clock -name W_CLK \
    -period $my_period_w \
    [get_ports W_clk]

create_clock -name R_CLK \
    -period $my_period_r \
    [get_ports R_clk]

set_clock_groups -asynchronous \
    -group {W_CLK} \
    -group {R_CLK}

set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns \
    -clock W_clk \
    [remove_from_collection [all_inputs] [get_ports {W_clk R_clk}]]

set_output_delay $my_output_delay_ns \
    -clock W_clk \
    [all_outputs]

compile -ungroup_all -map_effort medium

compile -incremental_mapping -map_effort medium

check_design
report_constraint -all_violators

#set filename [format "%s%s"  $my_toplevel ".vh"]
#write -f verilog -output $filename

#set filename [format "%s%s"  $my_toplevel ".sdc"]
#write_sdc $filename

#set filename [format "%s%s"  $my_toplevel ".db"]
#write -f db -hier -output $filename -xg_force_db

redirect timing.rep { report_timing }
redirect cell.rep { report_cell }
redirect power.rep { report_power }
redirect area.rep { report_area }

quit
