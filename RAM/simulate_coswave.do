# Create work library
vlib work
vmap work work

# Compile blocks
vcom Cosine.vhd Cosine_wavetb.vhd

# Run the Simulation
vsim work.TestBench

# Add signals from UUT
add wave -radix signed   -position end  sim:/testbench/UUT/CLK
add wave -radix signed   -position end  sim:/testbench/UUT/cos_table
add wave -radix unsigned -position end  sim:/testbench/address
add wave -radix unsigned -position end  sim:/testbench/phaseIncr
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /testbench/cosVal



# Run the simulation
run -all

# Full Zoom
wave zoom full