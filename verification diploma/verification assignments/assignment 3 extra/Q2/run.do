vlib work
vlog adder.v adder_pkg.svh adder_tb.svh +cover -covercells
vsim -voptargs=+acc work.adder_tb -cover
add wave *
coverage save -onexit adder_coverage.ucdb
run -all