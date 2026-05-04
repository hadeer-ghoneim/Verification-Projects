// package SPI_monitor_pkg;
//     import uvm_pkg::*;
//     import SPI_seq_item_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_monitor extends uvm_monitor;
//   `uvm_component_utils(spi_slave_monitor)
  
//   virtual spi_if vif;
//   uvm_analysis_port#(spi_slave_seq_item) mon_ap;
  
//   function new(string name = "spi_slave_monitor", uvm_component parent = null);
//     super.new(name, parent);
//     mon_ap = new("mon_ap", this);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if(!uvm_config_db#(virtual spi_if)::get(this, "", "spi_if", vif))
//       `uvm_fatal(get_type_name(), "Virtual interface not found")
//   endfunction
  
//   task run_phase(uvm_phase phase);
//     spi_slave_seq_item item;
//     bit [10:0] captured_data;
//     int bit_count = 0;
//     bit transaction_active = 0;
    
//     forever begin
//       @(vif.monitor_cb);
      
//       if (!vif.monitor_cb.rst_n) begin
//         // Reset condition
//         bit_count = 0;
//         captured_data = 0;
//         transaction_active = 0;
//       end else if (!vif.monitor_cb.SS_n && !transaction_active) begin
//         // Start of transaction
//         transaction_active = 1;
//         bit_count = 0;
//         captured_data = 0;
//       end else if (!vif.monitor_cb.SS_n && transaction_active) begin
//         // Capture data during transaction
//         captured_data = {captured_data[9:0], vif.monitor_cb.MOSI};
//         bit_count++;
        
//         if (bit_count == 11) begin
//           // Complete transaction captured
//           item = spi_slave_seq_item::type_id::create("item");
//           item.rst_n = vif.monitor_cb.rst_n;
//           item.SS_n = vif.monitor_cb.SS_n;
//           item.MOSI_data = captured_data;
//           item.command = captured_data[10:8];
//           item.tx_valid = vif.monitor_cb.tx_valid;
//           item.tx_data = vif.monitor_cb.tx_data;
//           item.MISO = vif.monitor_cb.MISO;
//           item.rx_valid = vif.monitor_cb.rx_valid;
//           item.rx_data = vif.monitor_cb.rx_data;
          
//           mon_ap.write(item);
//           transaction_active = 0;
//           bit_count = 0;
//         end
//       end else if (vif.monitor_cb.SS_n && transaction_active) begin
//         // Transaction interrupted
//         transaction_active = 0;
//         bit_count = 0;
//       end
//     end
//   endtask
// endclass
// endpackage