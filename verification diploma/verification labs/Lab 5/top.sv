////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
////////////////////////////////////////////////////////////////////////////////
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

  // Example 1
  // Clock generation
  // Instantiate the interface and DUT
  // run test using run_test task

  // Example 2
  // Set the virtual interface for the uvm test
