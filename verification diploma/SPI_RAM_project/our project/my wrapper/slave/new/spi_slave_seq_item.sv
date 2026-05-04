package spi_slave_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // ==========================================================================
  // Sequence Item - UPDATED for wrapper integration
  // ==========================================================================
  class spi_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_slave_seq_item)
    
    rand bit rst_n;
    rand bit [10:0] MOSI_data;
    // tx_data removed - will come from RAM in wrapper
    rand bit is_read_data;
    
    // Outputs - UPDATED
    bit MISO;
    bit rx_valid;
    bit [9:0] rx_data;
    bit SS_n;
    bit tx_valid;
    bit [7:0] tx_data; // Added to capture from RAM
    
    // Constraint 1: Reset deasserted most of the time
    constraint rst_c {
      rst_n dist {1 := 95, 0 := 5};
    }
    
    // Constraint 2: SS_n timing for wrapper
    constraint ss_n_timing_c {
      if (is_read_data) {
        // Extended transaction for read data (23 cycles)
        SS_n == 0; // Will be controlled by sequence
      } else {
        // Normal transaction (13 cycles)  
        SS_n == 0; // Will be controlled by sequence
      }
    }
    
    // Constraint 3: Valid command combinations
    constraint mosi_cmd_c {
      MOSI_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }
    
    // Better distribution for coverage
    constraint cmd_dist_c {
      MOSI_data[10:8] dist {
        3'b000 := 30,  // Write Address
        3'b001 := 25,  // Write Data
        3'b110 := 25,  // Read Address
        3'b111 := 20   // Read Data
      };
    }
    
    function new(string name = "spi_slave_seq_item");
      super.new(name);
    endfunction
    
    function void post_randomize();
      is_read_data = (MOSI_data[10:8] == 3'b111);
      tx_valid = is_read_data;
    endfunction
    
    // New function for wrapper integration
    function bit [1:0] get_opcode();
      return MOSI_data[10:9]; // Returns 2-bit opcode for RAM
    endfunction
    
    function bit [7:0] get_address();
      return MOSI_data[7:0]; // Returns address for RAM
    endfunction
    
    function bit [7:0] get_write_data();
      return MOSI_data[7:0]; // Returns write data for RAM
    endfunction
    
  endclass

endpackage