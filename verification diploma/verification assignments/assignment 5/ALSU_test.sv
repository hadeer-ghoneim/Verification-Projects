////////////////////////////////////////////////////////////////////////////////
// Author: Hadeer Ghoneim
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package ALSU_test_pkg;

  import ALSU_config_pkg::*;
  import ALSU_env_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ALSU_test extends uvm_test;
    `uvm_component_utils(ALSU_test)
    
    ALSU_env env;
    ALSU_config ALSU_cfg;

    function new(string name = "ALSU_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = ALSU_env::type_id::create("env", this);
      ALSU_cfg = ALSU_config::type_id::create("ALSU_cfg");

      if (!uvm_config_db #(virtual ALSU_if)::get(this, "", "ALSU_if", ALSU_cfg.ALSU))
        `uvm_fatal("build_phase", "Test - Unable to get the virtual interface");

      uvm_config_db #(ALSU_config)::set(this,"*", "CFG", ALSU_cfg);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      #100; `uvm_info("run_phase", "Inside the ALSU test using", UVM_MEDIUM)
      phase.drop_objection(this);
    endtask: run_phase

  endclass
endpackage

   // Example 1
  // Do the essentials (factory register & Constructor)
  // Build the enviornment in the build phase
  // Run in the test in the run phase, raise objection, add #100 delay then display a message using `uvm_info, then drop the objection

  // Example 2
  // Build the config object in the build phase
  // get the virtual interface and assign it to the virtual interface of the config object
  // set the config obj in the config db