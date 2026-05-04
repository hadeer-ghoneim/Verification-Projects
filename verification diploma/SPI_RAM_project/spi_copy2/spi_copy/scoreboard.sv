// package SPI_scoreboard_pkg;
//     import uvm_pkg::*;
//     import SPI_seq_item_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(spi_slave_scoreboard)
  
//   uvm_analysis_imp#(spi_slave_seq_item, spi_slave_scoreboard) sb_imp;
//   int pass_count = 0, fail_count = 0;
  
//   // Golden model instance (simplified reference)
//   bit [9:0] golden_rx_data;
//   bit golden_rx_valid;
//   bit golden_MISO;
  
//   function new(string name = "spi_slave_scoreboard", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     sb_imp = new("sb_imp", this);
//   endfunction
  
//   // Simple golden model logic
//   function void golden_model_predict(spi_slave_seq_item item);
//     golden_rx_valid = 0;
//     golden_MISO = 0;
    
//     if (!item.rst_n) begin
//       golden_rx_data = 0;
//       return;
//     end
    
//     // Predict rx_valid - should be high after 11 bits are received
//     if (item.MOSI_data inside {11'b000???????, 11'b001???????, 11'b110???????, 11'b111???????}) begin
//       golden_rx_valid = 1;
//       golden_rx_data = item.MOSI_data;
//     end
    
//     // Predict MISO for read data commands
//     if (item.MOSI_data[10:8] == 3'b111 && item.tx_valid) begin
//       golden_MISO = item.tx_data[7]; // First bit of tx_data
//     end
//   endfunction
  
//   function void write(spi_slave_seq_item item);
//     // Predict using golden model
//     golden_model_predict(item);
    
//     // Check reset behavior
//     if (!item.rst_n) begin
//       if (item.MISO === 0 && item.rx_valid === 0) begin
//         pass_count++;
//         `uvm_info(get_type_name(), "PASS: Reset behavior correct", UVM_HIGH)
//       end else begin
//         fail_count++;
//         `uvm_error(get_type_name(), 
//           $sformatf("FAIL: Outputs not cleared during reset - MISO=%b, rx_valid=%b",
//                    item.MISO, item.rx_valid))
//       end
//     end
    
//     // Check rx_valid timing and data
//     if (golden_rx_valid && !item.rx_valid) begin
//       fail_count++;
//       `uvm_error(get_type_name(), 
//         $sformatf("FAIL: rx_valid not asserted when expected - MOSI_data=0x%h", item.MOSI_data))
//     end else if (item.rx_valid && golden_rx_data !== item.rx_data) begin
//       fail_count++;
//       `uvm_error(get_type_name(), 
//         $sformatf("FAIL: rx_data mismatch - Expected: 0x%h, Got: 0x%h", 
//                  golden_rx_data, item.rx_data))
//     end else if (item.rx_valid) {
//       pass_count++;
//       `uvm_info(get_type_name(), 
//         $sformatf("PASS: Correct transaction - Command: %3b, Data: 0x%h", 
//                  item.command, item.rx_data), UVM_HIGH)
//     }
    
//     // Check MISO for read data commands
//     if (item.MOSI_data[10:8] == 3'b111 && item.tx_valid) begin
//       if (golden_MISO !== item.MISO) begin
//         fail_count++;
//         `uvm_error(get_type_name(), 
//           $sformatf("FAIL: MISO mismatch - Expected: %b, Got: %b", golden_MISO, item.MISO))
//       end
//     end
//   endfunction
  
//   function void report_phase(uvm_phase phase);
//     super.report_phase(phase);
//     `uvm_info(get_type_name(), 
//       $sformatf("SCOREBOARD SUMMARY: Pass Count: %0d, Fail Count: %0d", pass_count, fail_count), 
//       UVM_LOW)
      
//     if (fail_count == 0) begin
//       `uvm_info(get_type_name(), "*** TEST PASSED ***", UVM_NONE)
//     end else begin
//       `uvm_error(get_type_name(), "*** TEST FAILED ***")
//     end
//   endfunction
// endclass
// endpackage