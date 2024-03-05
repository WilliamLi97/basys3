set build_dir build

read_verilog -sv [glob ./src/seven-segment/*.sv]
read_xdc ./src/constraints/Basys-3.xdc

synth_design -top ss_top -part xc7a35tcpg236-1 -lint
