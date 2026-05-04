// package SPI_driver_pkg;
//     import uvm_pkg::*;
//     import SPI_seq_item_pkg::*;
//     import SPI_config_pkg::*;
//     `include "uvm_macros.svh"


// class spi_slave_driver extends uvm_driver#(spi_slave_seq_item);
//   `uvm_component_utils(spi_slave_driver)
  
//   virtual spi_if vif;
//   int bit_counter = 0;
//   bit [10:0] current_mosi_data;
  
//   function new(string name = "spi_slave_driver", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if(!uvm_config_db#(virtual spi_if)::get(this, "", "spi_if", vif))
//       `uvm_fatal(get_type_name(), "Virtual interface not found")
//   endfunction
  
//   task run_phase(uvm_phase phase);
//     forever begin
//       seq_item_port.get_next_item(req);
//       drive_transaction(req);
//       seq_item_port.item_done();
//     end
//   endtask
  
//   task drive_transaction(spi_slave_seq_item item);
//     // Apply reset and basic signals
//     vif.driver_cb.rst_n <= item.rst_n;
//     vif.driver_cb.tx_valid <= item.tx_valid;
//     vif.driver_cb.tx_data <= item.tx_data;
//     vif.driver_cb.SS_n <= item.SS_n;
    
//     if (!item.rst_n) begin
//       // Reset state
//       vif.driver_cb.MOSI <= 0;
//       @(vif.driver_cb);
//       return;
//     end
    
//     if (!item.SS_n) begin
//       // Drive MOSI data bit by bit
//       current_mosi_data = item.MOSI_data;
//       for (int i = 10; i >= 0; i--) begin
//         vif.driver_cb.MOSI <= current_mosi_data[i];
//         @(vif.driver_cb);
//       end
//     end else begin
//       vif.driver_cb.MOSI <= 0;
//       @(vif.driver_cb);
//     end
//   endtask
// endclass
// endpackage