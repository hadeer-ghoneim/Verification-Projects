vlib work
vlog alu_seq.sv  testing_pkg.sv tb.sv  +cover -covercells
vsim -voptargs=+acc work.tb -cover
add wave *
coverage save tb.ucdb -onexit 
run -all