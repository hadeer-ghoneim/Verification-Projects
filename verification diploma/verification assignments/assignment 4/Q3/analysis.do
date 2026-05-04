onerror resume
assertion fail -enable -limit none -log off /counter_top/dut/binding_inst/a_load/a_load
assertion pass -enable -limit 0 -log off /counter_top/dut/binding_inst/a_load/a_load
assertion action -cond fail -exec continue /counter_top/dut/binding_inst/a_load/a_load
assertion action -cond pass -exec continue /counter_top/dut/binding_inst/a_load/a_load
assertion action -cond start -exec continue /counter_top/dut/binding_inst/a_load/a_load
assertion action -cond antecedent -exec continue /counter_top/dut/binding_inst/a_load/a_load
assertion fail -enable -limit none -log off /counter_top/dut/binding_inst/a_increment/a_increment
assertion pass -enable -limit 0 -log off /counter_top/dut/binding_inst/a_increment/a_increment
assertion action -cond fail -exec continue /counter_top/dut/binding_inst/a_increment/a_increment
assertion action -cond pass -exec continue /counter_top/dut/binding_inst/a_increment/a_increment
assertion action -cond start -exec continue /counter_top/dut/binding_inst/a_increment/a_increment
assertion action -cond antecedent -exec continue /counter_top/dut/binding_inst/a_increment/a_increment
assertion fail -enable -limit none -log off /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion pass -enable -limit 0 -log off /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion action -cond fail -exec continue /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion action -cond pass -exec continue /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion action -cond start -exec continue /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion action -cond antecedent -exec continue /counter_top/dut/binding_inst/a_decrement/a_decrement
assertion fail -enable -limit none -log off /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion pass -enable -limit 0 -log off /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion action -cond fail -exec continue /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion action -cond pass -exec continue /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion action -cond start -exec continue /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion action -cond antecedent -exec continue /counter_top/dut/binding_inst/a_max_count/a_max_count
assertion fail -enable -limit none -log off /counter_top/dut/binding_inst/a_zero/a_zero
assertion pass -enable -limit 0 -log off /counter_top/dut/binding_inst/a_zero/a_zero
assertion action -cond fail -exec continue /counter_top/dut/binding_inst/a_zero/a_zero
assertion action -cond pass -exec continue /counter_top/dut/binding_inst/a_zero/a_zero
assertion action -cond start -exec continue /counter_top/dut/binding_inst/a_zero/a_zero
assertion action -cond antecedent -exec continue /counter_top/dut/binding_inst/a_zero/a_zero

fcover configure /counter_top/dut/binding_inst/c_load/c_load -enable -at_least 1 -weight 1 -log off -include
fcover configure /counter_top/dut/binding_inst/c_increment/c_increment -enable -at_least 1 -weight 1 -log off -include
fcover configure /counter_top/dut/binding_inst/c_decrement/c_decrement -enable -at_least 1 -weight 1 -log off -include
fcover configure /counter_top/dut/binding_inst/c_max_count/c_max_count -enable -at_least 1 -weight 1 -log off -include
fcover configure /counter_top/dut/binding_inst/c_zero/c_zero -enable -at_least 1 -weight 1 -log off -include
