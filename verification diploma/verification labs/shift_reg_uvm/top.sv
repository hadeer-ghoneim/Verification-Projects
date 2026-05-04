////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"
import shift_reg_test_pkg::*;

module top();
  bit clk;
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  shift_reg_if shiftregif (clk);
  shift_reg DUT(
    .clk(clk),
    .reset(shiftregif.reset),
    .serial_in(shiftregif.serial_in),
    .direction(shiftregif.direction),
    .mode(shiftregif.mode),
    .datain(shiftregif.datain),
    .dataout(shiftregif.dataout)
  );
  
  initial begin
    uvm_config_db#(virtual shift_reg_if)::set(null, "uvm_test_top", "SHIFT_REG_IF", shiftregif);
    run_test("shift_reg_test");
  end

endmodule