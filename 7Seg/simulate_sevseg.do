# Create work library
vlib work
vmap work work

# Compile blocks
vcom SevSeg.vhd SevSeg_tb.vhd

# Run the Simulation
vsim work.TestBench

# Set the waves
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/DONE
add wave -noupdate /testbench/UUT/MCLK
add wave -noupdate /testbench/UUT/ENABLE
add wave -noupdate /testbench/UUT/MODE
add wave -noupdate /testbench/UUT/characters
add wave -radix unsigned -noupdate /testbench/UUT/AN
add wave -radix unsigned -noupdate /testbench/UUT/SEG
add wave -radix unsigned -noupdate /testbench/UUT/anode

# Run the simulation
run -all

# Full Zoom
wave zoom full