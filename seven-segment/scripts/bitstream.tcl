set build_dir build

open_checkpoint $build_dir/route.dcp

write_bitstream -force $build_dir/bitstream.bit
