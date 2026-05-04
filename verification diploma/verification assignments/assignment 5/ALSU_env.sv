////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package ALSU_env_pkg;

  import ALSU_driver_pkg::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ALSU_env extends uvm_env;

  `uvm_component_utils(ALSU_env)
    ALSU_driver driver;

    function new(string name = "ALSU_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = ALSU_driver::type_id::create("driver", this);
    endfunction: build_phase

  endclass   : ALSU_env
endpackage : ALSU_env_pkg