vlib work
vlog FSM_010.v  FSM_pkg.svh FSM_tb.svh  +cover -covercells
vsim -voptargs=+acc work.FSM_tb -cover
add wave *
coverage save FSM_tb.ucdb -onexit 
run -all