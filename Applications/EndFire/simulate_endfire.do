# Create work library
vlib work
vmap work work

# Compile blocks
vcom AXItoI2S.vhd Cosine.vhd SevSeg.vhd Endfire_tb.vhd

# Run the Simulation
vsim work.TestBench

# Set the waves
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /testbench/d1Out
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /testbench/d2Out
add wave -noupdate /testbench/MODE_tb
add wave -noupdate /testbench/ENABLE_tb
add wave -noupdate /testbench/i2sClk
add wave -noupdate /testbench/I2S_inst/LRCLK
add wave -noupdate /testbench/I2S_inst/BCLK
add wave -noupdate /testbench/I2S_inst/READY
add wave -noupdate /testbench/I2S_inst/bitCntr
add wave -noupdate /testbench/I2S_inst/PHONE1
add wave -noupdate /testbench/I2S_inst/PHONE2
add wave -noupdate /testbench/COS_ROM_inst/ADDR2
add wave -noupdate /testbench/COS_ROM_inst/ADDR1


# Run the simulation
run -all

# Full Zoom
wave zoom full
