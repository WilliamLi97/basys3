set build_dir build
set reports_dir reports

read_verilog -sv [glob ./src/*/*.sv]
read_xdc ./src/constraints/Basys-3.xdc

synth_design -top uart_top -part xc7a35tcpg236-1
opt_design

report_utilization -file $reports_dir/synthesis_utilization.txt

write_checkpoint -force $build_dir/synthesis.dcp
