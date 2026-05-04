vlib work
vlog priority_enc.v decoder_3to8.v assertions_module.svh tb_complete.svh  +cover -covercells
vsim -voptargs=+acc work.tb_complete -cover
add wave *
coverage save tb_complete.ucdb -onexit 
run -all