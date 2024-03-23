set build_dir build
set reports_dir reports

open_checkpoint $build_dir/place.dcp

route_design

report_timing -file $reports_dir/route_timing.txt -nworst 5
report_timing_summary -file $reports_dir/route_timing_summary.txt
report_io -file $reports_dir/route_io.txt
report_drc -file $reports_dir/route_drc.txt

write_checkpoint -force $build_dir/route.dcp
