// package SPI_coverage_pkg;
//     import uvm_pkg::*;
//     import SPI_seq_item_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_coverage extends uvm_subscriber#(spi_slave_seq_item);
//   `uvm_component_utils(spi_slave_coverage)
  
//   spi_slave_seq_item cov_item;
  
//   covergroup spi_cov with function sample(spi_slave_seq_item item);
//     // Coverpoint 1: rx_data[9:8] values
//     rx_data_cp: coverpoint item.rx_data[9:8] {
//       bins write_addr = {2'b00};
//       bins write_data = {2'b01};
//       bins read_addr  = {2'b10};
//       bins read_data  = {2'b11};
//     }
    
//     // Coverpoint 2: SS_n sequences
//     ss_n_cp: coverpoint item.SS_n {
//       bins ss_low  = {0};
//       bins ss_high = {1};
//     }
    
//     // Coverpoint 3: MOSI command validation
//     mosi_cmd_cp: coverpoint item.MOSI_data[10:8] {
//       bins write_addr_cmd = {3'b000};
//       bins write_data_cmd = {3'b001};
//       bins read_addr_cmd  = {3'b110};
//       bins read_data_cmd  = {3'b111};
//     }
    
//     // Cross coverage 4: SS_n and MOSI commands
//     ss_mosi_cross: cross ss_n_cp, mosi_cmd_cp;
    
//     // Coverpoint 5: Command transitions
//     command_trans_cp: coverpoint item.MOSI_data[10:8] {
//       bins trans_wa_wd = (3'b000 => 3'b001);
//       bins trans_ra_rd = (3'b110 => 3'b111);
//     }
    
//   endgroup
  
//   function new(string name = "spi_slave_coverage", uvm_component parent = null);
//     super.new(name, parent);
//     spi_cov = new();
//   endfunction
  
//   function void write(spi_slave_seq_item t);
//     if (t.rst_n) begin // Only sample when not in reset
//       cov_item = t;
//       spi_cov.sample(cov_item);
//     end
//   endfunction
  
//   function void report_phase(uvm_phase phase);
//     super.report_phase(phase);
//     `uvm_info(get_type_name(), $sformatf("Coverage: %0.2f%%", spi_cov.get_inst_coverage()), UVM_LOW)
//   endfunction
// endclass
// endpackage