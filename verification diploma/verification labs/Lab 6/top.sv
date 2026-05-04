import shift_reg_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();

  bit clk, reset;

  initial begin
    forever
      #1 clk = ~clk;
  end

  shift_reg_if shiftregif (clk);
  shift_reg DUT(shiftregif.clk, shiftregif.reset, shiftregif.serial_in, shiftregif.direction, shiftregif.mode, shiftregif.datain, shiftregif.dataout);

  initial begin
    uvm_config_db#(virtual shift_reg_if)::set(null, "uvm_test_top", "shift_reg_if", shiftregif);
    run_test("shift_reg_test");
  end

endmodule
