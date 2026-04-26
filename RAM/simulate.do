# Create work library
vlib work
vmap work work

# Compile blocks
vcom RAM.vhd RAM_tb.vhd

# Run the Simulation
vsim work.TestBench

# Add signals from UUT
add wave -radix unsigned -position end  sim:/testbench/clk
add wave -radix unsigned -position end  sim:/testbench/DONE
add wave -radix unsigned -position end  sim:/testbench/UUT/rxReady
add wave -radix unsigned -position end  sim:/testbench/UUT/RX_VALID
add wave -radix unsigned -position end  sim:/testbench/UUT/RX_DATA
add wave -radix unsigned -position end  sim:/testbench/rxData
add wave -radix unsigned -position end  sim:/testbench/txValid
add wave -radix unsigned -position end  sim:/testbench/UUT/TX_DATA
add wave -radix unsigned -position end  sim:/testbench/UUT/head
add wave -radix unsigned -position end  sim:/testbench/UUT/tail
add wave -radix unsigned -position end  sim:/testbench/UUT/count
add wave -radix unsigned -position end  sim:/testbench/UUT/count_z1
add wave -radix unsigned -position end  sim:/testbench/UUT/ram

# Run the simulation
run 30 ms

# Full Zoom
wave zoom full