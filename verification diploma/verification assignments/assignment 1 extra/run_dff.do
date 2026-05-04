vlib work
vlog mux4to1.v tb_mux4to1.svh  +cover -covercells
vsim -voptargs=+acc work.tb_mux4to1 -cover
add wave *
coverage save tb_mux4to1.ucdb -onexit -du work.mux4to1
run -all