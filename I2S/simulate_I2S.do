# Create work library
vlib work
vmap work work

# Compile blocks
vcom AXItoI2S.vhd AxiToI2S_tb.vhd

# Run the Simulation
vsim work.TestBench

# Set the waves
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/UUT/MCLK
add wave -noupdate /testbench/UUT/BCLK
add wave -noupdate /testbench/UUT/LRCLK
add wave -radix unsigned -noupdate /testbench/UUT/d1InReg
add wave -noupdate /testbench/UUT/bitCntr
add wave -radix unsigned -noupdate /testbench/UUT/DIN1
add wave -noupdate /testbench/UUT/PHONE1
add wave -noupdate /testbench/UUT/READY
add wave -noupdate /testbench/UUT/bitTransition




TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4999999336 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4999999050 ps} {5000000050 ps}

# Run the simulation
run -all

# Full Zoom
wave zoom full