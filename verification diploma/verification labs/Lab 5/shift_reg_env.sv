////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package shift_reg_env_pkg;

import shift_reg_driver_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class shift_reg_env extends uvm_env;

`uvm_component_utils(shift_reg_env)
  shift_reg_driver driver;
  // Example 1
  // Do the essentials (factory register & Constructor)
  function new(string name = "shift_reg_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Example 2
  // Build the driver in the build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = shift_reg_driver::type_id::create("driver", this);
  endfunction: build_phase

endclass   : shift_reg_env
endpackage : shift_reg_env_pkg