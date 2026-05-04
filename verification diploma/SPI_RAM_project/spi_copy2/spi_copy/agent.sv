
// package SPI_agent_pkg;
//     import uvm_pkg::*;
//     import SPI_sequencer_pkg::*;
//     import SPI_config_pkg::*;
//     import SPI_driver_pkg::*;
//     import SPI_monitor_pkg::*;
//     import SPI_seq_item_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_agent extends uvm_agent;
//   `uvm_component_utils(spi_slave_agent)
  
//   spi_slave_driver drv;
//   spi_slave_monitor mon;
//   spi_slave_sequencer sqr;
  
//   function new(string name = "spi_slave_agent", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     mon = spi_slave_monitor::type_id::create("mon", this);
//     if (get_is_active() == UVM_ACTIVE) begin
//       drv = spi_slave_driver::type_id::create("drv", this);
//       sqr = spi_slave_sequencer::type_id::create("sqr", this);
//     end
//   endfunction
  
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     if (get_is_active() == UVM_ACTIVE) begin
//       drv.seq_item_port.connect(sqr.seq_item_export);
//     end
//   endfunction
// endclass

// typedef uvm_sequencer#(spi_slave_seq_item) spi_slave_sequencer;
// endpackage