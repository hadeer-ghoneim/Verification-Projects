vlib work
vlog -sv *.sv +cover
vsim -voptargs=+acc counter_top -cover
add wave *
coverage save counter_top.ucdb -onexit
run -all