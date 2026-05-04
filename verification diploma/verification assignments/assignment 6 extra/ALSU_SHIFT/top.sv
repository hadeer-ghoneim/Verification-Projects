import uvm_pkg::*;
    `include "uvm_macros.svh"
import test_pkg::*;

module top();
bit clk=0;
always #5 clk=!clk;

ALSU_if if_t(clk);
shift_reg_if sr_t();
shift_reg SR(sr_t);
ALSU DUT (if_t,sr_t);

bind ALSU Asseritions AS(if_t);

initial begin
    uvm_config_db #(virtual ALSU_if)::set(null,"*","ALSU_K",if_t);
    uvm_config_db #(virtual shift_reg_if)::set(null,"*","SHIFT_K",sr_t);
    run_test("ALSU_test");
end

endmodule


/*
coverage exclude -dirpath /top/DUT/AS/bypass2_cover /top/DUT/AS/OR2_cover /top/DUT/AS/XOR2_cover /top/DUT/AS/halfADD_cover
coverage exclude -src ALSU.sv -line 75 -code b
coverage exclude -src ALSU.sv -line 86 -code b
coverage exclude -src ALSU.sv -line 96 -code b
coverage exclude -src ALSU.sv -line 105 -code b
coverage exclude -src ALSU.sv -line 107 -code b
coverage exclude -src ALSU.sv -line 108 -code s

quit -sim
vcover report Top_tb.ucdb -details -all -output coverage_report.txt

*/