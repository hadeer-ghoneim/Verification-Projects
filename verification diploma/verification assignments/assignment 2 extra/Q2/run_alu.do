vlib work
vlog ALU.v  ALU_pkg.svh ALU_tb.svh  +cover -covercells
vsim -voptargs=+acc work.ALU_tb -cover
add wave *
coverage save ALU_tb.ucdb -onexit -du work.ALU
run -all