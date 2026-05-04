////////////////////////////////////////////////////////////////////////////////
// Author: Hadeer Ghoneim
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
////////////////////////////////////////////////////////////////////////////////

import ALSU_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();

  bit clk, rst;

  initial begin
    forever
      #1 clk = ~clk;
  end

  ALSU_if ALSUif (clk);
  ALSU DUT (ALSUif.A, ALSUif.B, ALSUif.cin, ALSUif.serial_in, ALSUif.red_op_A, 
  ALSUif.red_op_B, ALSUif.opcode, ALSUif.bypass_A, ALSUif.bypass_B, 
  ALSUif.clk, ALSUif.rst, ALSUif.direction, ALSUif.leds, ALSUif.out);
  initial begin
    uvm_config_db#(virtual ALSU_if)::set(null, "uvm_test_top", "ALSU_if", ALSUif);
    run_test("ALSU_test");
  end

endmodule

  // Example 1
  // Clock generation
  // Instantiate the interface and DUT
  // run test using run_test task

  // Example 2
  // Set the virtual interface for the uvm test
