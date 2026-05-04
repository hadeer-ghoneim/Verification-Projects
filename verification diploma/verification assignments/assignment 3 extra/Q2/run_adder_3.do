vlib work
vlog adder.v  adder_pkg.svh adder_tb.svh  +cover -covercells
vsim -voptargs=+acc work.adder_tb -cover
add wave *
coverage save adder_pkg.ucdb -onexit 
run -all