vlib work
vlog my_mem.sv  mem_pkg.sv my_mem_tb.sv  +cover -covercells
vsim -voptargs=+acc work.my_mem_tb -cover
add wave *
coverage save mem.ucdb -onexit 
run -all