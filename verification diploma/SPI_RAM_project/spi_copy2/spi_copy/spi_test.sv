// package SPI_test_pkg;
//     import uvm_pkg::*;
//     import SPI_env_pkg::*;
//     import SPI_config_pkg::*;
//     import SPI_sequence_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_test extends uvm_test;
//   `uvm_component_utils(spi_slave_test)
  
//   spi_slave_env env;
  
//   function new(string name = "spi_slave_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     env = spi_slave_env::type_id::create("env", this);
//   endfunction
  
//   task run_phase(uvm_phase phase);
//     reset_sequence rst_seq;
//     main_sequence main_seq;
    
//     phase.raise_objection(this);
    
//     `uvm_info(get_type_name(), "Starting SPI Slave Test", UVM_LOW)
    
//     // Run reset sequence
//     rst_seq = reset_sequence::type_id::create("rst_seq");
//     rst_seq.start(env.agt.sqr);
    
//     // Allow some time after reset
//     #100;
    
//     // Run main sequence
//     main_seq = main_sequence::type_id::create("main_seq");
//     main_seq.start(env.agt.sqr);
    
//     // Wait for completion
//     #5000;
//     phase.drop_objection(this);
    
//     `uvm_info(get_type_name(), "SPI Slave Test Completed", UVM_LOW)
//   endtask
// endclass
// endpackage