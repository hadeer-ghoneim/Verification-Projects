//new -all

// Top Module
module top();
  bit clk, reset;

  initial begin
    forever
      #1 clk = ~clk;
  end

  alu_if aluif (clk);
  ALU DUT(aluif);

  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "uvm_test_top", "ALU_IF", aluif);
    run_test("alu_test");
  end
endmodule

// Configuration Class
class alu_config extends uvm_object;
  `uvm_object_utils(alu_config)
  
  virtual alu_if alu_vif;

  function new(string name = "alu_config");
    super.new(name);
  endfunction
endclass

// Test Class
class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)
  
  alu_env env;
  alu_config alu_cfg;

  function new(string name = "alu_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
    alu_cfg = alu_config::type_id::create("alu_cfg");

    if (!uvm_config_db #(virtual alu_if)::get(this, "", "ALU_IF", alu_cfg.alu_vif))
      `uvm_fatal("build_phase", "Test - Unable to get the virtual interface");

    uvm_config_db #(alu_config)::set(this, "", "CFG", alu_cfg);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    #100; `uvm_info("run_phase", "Welcome to the UVM Env.", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask: run_phase
endclass: alu_test

// Environment Class
class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)
  
  alu_driver driver;

  function new(string name = "alu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = alu_driver::type_id::create("driver", this);
  endfunction: build_phase
endclass

// Driver Class
class alu_driver extends uvm_driver;
  `uvm_component_utils(alu_driver)
  
  virtual alu_if alu_vif;
  alu_config alu_cfg;

  function new(string name = "alu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(alu_config)::get(this, "", "CFG", alu_cfg))
      `uvm_fatal("build_phase", "Unable to get configuration object");
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    alu_vif = alu_cfg.alu_vif;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    alu_vif.A = 0; alu_vif.B = 0; alu_vif.opcode = 0; alu_vif.reset = 1;
    @(negedge alu_vif.clk); alu_vif.reset = 0;
    forever begin
      @(negedge alu_vif.clk);
      alu_vif.opcode = $random; alu_vif.A = $random; alu_vif.B = $random;
    end
  endtask
endclass

//old
class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)

  alu_env env;

  // Constructor
  function new(string name = "alu_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    #100;
    uvm_info("run_phase", "Welcome to the UVM Env.", UVM_MEDIUM);

    phase.drop_objection(this);
  endtask : run_phase

endclass : alu_test


package alu_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  `include "alu_env.sv"
  `include "alu_test.sv"
endpackage : alu_test_pkg

import alu_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();
  bit clk;

  // Clock generation
  initial begin
    forever #1 clk = ~clk;
  end

  // Instantiate Interface
  alu_if aluif(clk);

  // Instantiate DUT
  ALU DUT(aluif);

  // Run the UVM test
  initial begin
    run_test("alu_test");
  end

endmodule

class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)

  // Constructor
  function new(string name = "alu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : alu_env

/*
Dears,
Please ignore this message until our meeting tomorrow. It contains detailed instructions for the lab you will be working on, and I am sharing it here in advance so that you can easily access it during the session.

1- Create config object class inside a package
> import UVM package and include UVM macros file
> Add uvm_object_utils macro
> Constructor
> Declare the virtual interface

2- Create uvm driver class inside a package
> import UVM package and include UVM macros file
> Add uvm_component_utils macro
> Declare virtual interface and configuration object handle
> Constructor
> Build phase: get the configuration object from configuration database
> Connect phase: connect the virtual interface to the virtual interface of the configuration object
> run phase: Drive the interface, start by reseting the design then applying random data using $random with each clock edge

Notes:
1- Import the above packages in the appropriate files shared with you.
2- Add the above files created in the correct order in the src_files.list
3- The remaining files shared with you have the steps to be done inside of them.
*/
