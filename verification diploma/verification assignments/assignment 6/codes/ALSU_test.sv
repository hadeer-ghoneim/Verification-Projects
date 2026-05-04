package ALSU_test_pkg;

  import ALSU_config_pkg::*;
  import ALSU_env_pkg::*;
  import ALSU_main_sequence_pkg::*;
  import ALSU_reset_sequence_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
    
  class ALSU_test extends uvm_test;
    `uvm_component_utils(ALSU_test)

    ALSU_env env;
    ALSU_config ALSU_cfg;
    virtual ALSU_if ALSU_vif;
    ALSU_main_sequence main_seq;
    ALSU_reset_sequence reset_seq;


    function new(string name = "ALSU_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      env = ALSU_env::type_id::create("env", this);
      ALSU_cfg = ALSU_config::type_id::create("ALSU_cfg", this);
      main_seq = ALSU_main_sequence::type_id::create("main_seq", this);
      reset_seq = ALSU_reset_sequence::type_id::create("reset_seq", this);

      if (!uvm_config_db #(virtual ALSU_if)::get(this, "", "ALSU_if", ALSU_vif))
        `uvm_fatal("build_phase", "Unable to get virtual interface")

      ALSU_cfg.ALSU_vif = ALSU_vif;
      uvm_config_db #(ALSU_config)::set(this, "*", "CFG", ALSU_cfg);

    endfunction


    task run_phase(uvm_phase phase);

      super.run_phase(phase);

      phase.raise_objection(this);

      `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
      reset_seq.start(env.agt.sqr);

      `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)
      `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)

      main_seq.start(env.agt.sqr);
      `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

      phase.drop_objection(this);

    endtask


  endclass

endpackage