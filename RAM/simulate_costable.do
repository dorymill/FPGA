# Create work library
vlib work
vmap work work

# Compile blocks
vcom Cosine.vhd Cosine_tb.vhd

# Run the Simulation
vsim work.TestBench

# Add signals from UUT
add wave -radix signed   -position end  sim:/testbench/UUT/CLK
add wave -radix signed   -position end  sim:/testbench/UUT/cos_table
add wave -radix unsigned -position end  sim:/testbench/address
add wave -format analog sim:/testbench/cosVal


# Run the simulation
run -all

# Full Zoom
wave zoom full