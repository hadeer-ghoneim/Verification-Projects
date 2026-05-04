package ALSU_driver_pkg;

  import ALSU_config_pkg::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ALSU_driver extends uvm_driver;
    `uvm_component_utils(ALSU_driver)
    
    virtual ALSU_if ALSU;
    ALSU_config ALSU_cfg;

    function new(string name = "ALSU_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(ALSU_config)::get(this, "", "CFG", ALSU_cfg))
        `uvm_fatal("build_phase", "Unable to get configuration object");
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ALSU = ALSU_cfg.ALSU;
    endfunction

    task run_phase(uvm_phase phase);

      super.run_phase(phase);
      ALSU.A = 0; ALSU.B = 0; ALSU.cin = 0; ALSU.serial_in = 0; ALSU.red_op_A  = 0;
      ALSU.red_op_B = 0; ALSU.opcode = 0; ALSU.bypass_A = 0; ALSU.bypass_B  = 0;
      ALSU.direction = 0; ALSU.rst = 1;
      @(negedge ALSU.clk); ALSU.rst = 0;

      forever begin

        @(negedge ALSU.clk);
      ALSU.A = $random; ALSU.B = $random; ALSU.cin = $random; 
      ALSU.serial_in = $random; ALSU.red_op_A  = $random;
      ALSU.red_op_B = $random; ALSU.opcode = $random; 
      ALSU.bypass_A = $random; ALSU.bypass_B  = $random;
      ALSU.direction = $random;

      end
    endtask

  endclass
  
endpackage
