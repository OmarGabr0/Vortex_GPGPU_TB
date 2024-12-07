vlib work
vlog barret_reduction.v barret_reduction_tb.v
vsim -voptargs=+accs work.barret_tb 
add wave *

run -all