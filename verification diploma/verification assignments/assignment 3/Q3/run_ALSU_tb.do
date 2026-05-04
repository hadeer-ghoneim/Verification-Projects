vlib work
vlog ALSU.v package_q_3.svh question_3_tb.svh  +cover -covercells
vsim -voptargs=+acc work.question_3_tb -cover
add wave *
coverage save question_3_tb.ucdb -onexit 
run -all