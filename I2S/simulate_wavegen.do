# Create work library
vlib work
vmap work work

# Compile blocks
vcom AXItoI2S.vhd ../RAM/Cosine.vhd WaveGen_tb.vhd

# Run the Simulation
vsim work.TestBench

# Set the waves
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /testbench/AXIToI2S_UUT/d1InReg
add wave -noupdate /testbench/AXIToI2S_UUT/MCLK
add wave -noupdate /testbench/AXIToI2S_UUT/LRCLK
add wave -noupdate /testbench/AXIToI2S_UUT/BCLK
add wave -noupdate /testbench/AXIToI2S_UUT/READY
add wave -noupdate /testbench/AXIToI2S_UUT/PHONE1

# Run the simulation
run -all

# Full Zoom
wave zoom full