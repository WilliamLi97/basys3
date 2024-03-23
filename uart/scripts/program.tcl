set build_dir build

open_hw_manager
connect_hw_server -url localhost:3121

current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210183B82494A]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210183B82494A]
open_hw_target

current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]

set_property PROGRAM.FILE $build_dir/bitstream.bit [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]
