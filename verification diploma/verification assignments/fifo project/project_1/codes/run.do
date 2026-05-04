vlib work
vlog -f src_files.list  +cover -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all   -cover
add wave /top/v_if/*
coverage save fifo_project.ucdb -onexit 
run -all
