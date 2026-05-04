vlib work
vlog counter.v package.svh question_2_tb.svh  +cover -covercells
vsim -voptargs=+acc work.question_2_tb -cover
add wave *
coverage save question_2_tb.ucdb -onexit 
run -all