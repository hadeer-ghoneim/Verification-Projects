vlib work
vlog *v +cover -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover

add wave -position insertpoint sim:/top/if_t/*
add wave -position insertpoint sim:/top/sr_t/*
coverage save Top_tb.ucdb -onexit 
run -all

