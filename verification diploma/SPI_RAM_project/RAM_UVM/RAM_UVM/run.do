vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.top 
add wave /top/r_if/*
coverage save -du RAM RAM_test.udcb -onexit
run -all