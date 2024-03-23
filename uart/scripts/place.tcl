set build_dir build
set reports_dir reports

open_checkpoint $build_dir/synthesis.dcp

place_design

report_utilization -file $reports_dir/place_utilization.txt
report_timing -file $reports_dir/place_timing.txt -nworst 5

write_checkpoint -force $build_dir/place.dcp
