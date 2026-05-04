// package SPI_seq_item_pkg;
//     import uvm_pkg::*;
//     `include "uvm_macros.svh"


// class spi_slave_seq_item extends uvm_sequence_item;
//   `uvm_object_utils(spi_slave_seq_item)
  
//   rand bit rst_n;
//   rand bit SS_n;
//   rand bit [10:0] MOSI_data;
//   rand bit tx_valid;
//   rand bit [7:0] tx_data;
  
//   bit MISO;
//   bit rx_valid;
//   bit [9:0] rx_data;
//   bit [2:0] command;
  
//   // Constraint 1: Reset deasserted most of the time
//   constraint rst_c {
//     rst_n dist {1 := 95, 0 := 5};
//   }
  
//   // Constraint 3: Valid command combinations
//   constraint mosi_cmd_c {
//     MOSI_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
//   }
  
//   // Constraint 4: tx_valid high for read data
//   constraint tx_valid_c {
//     tx_valid == (MOSI_data[10:8] == 3'b111);
//   }
  
//   // SS_n timing constraint
//   constraint ss_n_timing_c {
//     SS_n dist {0 := 80, 1 := 20};
//   }
  
//   function new(string name = "spi_slave_seq_item");
//     super.new(name);
//   endfunction
  
//   function string convert2string();
//     return $sformatf("rst_n=%b, SS_n=%b, MOSI_data=0x%h, command=%3b, tx_valid=%b", 
//                     rst_n, SS_n, MOSI_data, MOSI_data[10:8], tx_valid);
//   endfunction
  
// endclass
// endpackage