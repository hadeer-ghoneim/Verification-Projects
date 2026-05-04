package RAM_test_pkg;
import RAM_env_pkg::*;
import RAM_config_pkg::*;
import reset_sequence_pkg::*;
import write_only_sequence_pkg::*;
import read_only_sequence_pkg::*;
import write_read_sequence_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

  class RAM_test extends uvm_test;
  
    `uvm_component_utils(RAM_test)

    RAM_env env;
    RAM_config_obj RAM_cfg;
    virtual RAM_if RAM_vif;
    RAM_reset_sequence reset_seq;
    RAM_write_only_sequence write_seq; 
    RAM_read_only_sequence read_seq;
    RAM_write_read_sequence write_read_seq;

    function new(string name = "RAM_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = RAM_env::type_id::create("env", this);
      RAM_cfg = RAM_config_obj::type_id::create("RAM_cfg");
      reset_seq = RAM_reset_sequence::type_id::create("reset_seq");
      write_seq = RAM_write_only_sequence::type_id::create("write_seq");
      read_seq = RAM_read_only_sequence::type_id::create("read_seq");
      write_read_seq = RAM_write_read_sequence::type_id::create("write_read_seq");

      if(!uvm_config_db #(virtual RAM_if)::get(this, "", "RAM_IF", RAM_cfg.RAM_vif))
        `uvm_fatal("build phase", "Unabble to get V_IF");
      uvm_config_db #(RAM_config_obj)::set(this, "*", "CFG", RAM_cfg);
      
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info("run_phase", "reset asserted", UVM_LOW);
      reset_seq.start(env.agt.sqr); //since sqr is in agent NOT environment 
      `uvm_info("run_phase", "reset deasserted", UVM_LOW);
    
      // #100;
      // `uvm_info("run_phase", "write_stimulus", UVM_LOW);
      // write_seq.start(env.agt.sqr);
      // `uvm_info("run_phase", "end stimulus", UVM_LOW);
      
      // #100;
      // `uvm_info("run_phase", "read_stimulus", UVM_LOW);
      // read_seq.start(env.agt.sqr);
      // `uvm_info("run_phase", "end stimulus", UVM_LOW);

      #100;
      `uvm_info("run_phase", "write_read_stimulus", UVM_LOW);
      write_read_seq.start(env.agt.sqr);
      `uvm_info("run_phase", "end stimulus", UVM_LOW);

       phase.drop_objection(this);
    endtask

  endclass: RAM_test
endpackage