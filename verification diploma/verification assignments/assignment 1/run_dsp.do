vlib work
vlog DSP.v DSP_Block.v DSP_tb.svh  +cover -covercells
vsim -voptargs=+acc work.DSP_tb -cover
add wave *
coverage save DSP_tb.ucdb -onexit -du work.DSP
run -all