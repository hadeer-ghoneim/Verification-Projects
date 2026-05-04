package shift_reg_driver_pkg;

import shift_reg_config_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class shift_reg_driver extends uvm_driver;
  `uvm_component_utils(shift_reg_driver)
  
  virtual shift_reg_if shift_reg;
  shift_reg_config shift_reg_cfg;

  function new(string name = "shift_reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(shift_reg_config)::get(this, "", "CFG", shift_reg_cfg))
      `uvm_fatal("build_phase", "Unable to get configuration object");
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    shift_reg = shift_reg_cfg.shift_reg;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    shift_reg.serial_in = 0; shift_reg.direction = 0; shift_reg.datain = 0 ; shift_reg.mode = 0; shift_reg.reset = 1;
    @(negedge shift_reg.clk); shift_reg.reset = 0;
    forever begin
      @(negedge shift_reg.clk);
    shift_reg.serial_in = $random; shift_reg.direction = $random; shift_reg.datain = $random; shift_reg.mode = $random;
    end

  endtask
endclass
endpackage
