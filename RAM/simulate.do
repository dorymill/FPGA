# Create work library
vlib work
vmap work work

# Compile blocks
vcom RAM.vhd RAM_tb.vhd

# Run the Simulation
vsim work.TestBench

# Add signals from UUT
add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/DONE
add wave -position end  sim:/testbench/UUT/rxReady
add wave -position end  sim:/testbench/UUT/RX_VALID
add wave -position end  sim:/testbench/txValid
add wave -position end  sim:/testbench/UUT/TX_DATA
add wave -position end  sim:/testbench/UUT/head
add wave -position end  sim:/testbench/UUT/tail
add wave -position end  sim:/testbench/UUT/count
add wave -position end  sim:/testbench/UUT/count_z1
add wave -position end  sim:/testbench/UUT/ram

# Run the simulation
run 10 ms

# Full Zoom
wave zoom full