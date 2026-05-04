package sequnce_ram_item;
import uvm_pkg::*;
`include "uvm_macros.svh"

class sequnce_ram_item extends uvm_sequence_item;
    
    `uvm_object_utils(sequnce_ram_item)
    
    rand bit [7:0] address;
    rand bit [7:0] write_data;
    bit [7:0] read_data;
    rand bit rst_n;
    rand bit rx_valid;
    
    // SPI frame data
    logic [9:0] din;
    logic [7:0] dout, dout_ref;
    logic tx_valid, tx_valid_ref;


    function new(string name = "sequnce_ram_item");
        super.new(name);
    endfunction


    // Constraints for SPI_Wrapper integration
    constraint c_reset_low_prob { rst_n dist { 0 := 5, 1 := 95 };}
    constraint c_rx_valid_low_prob { rx_valid dist { 0 := 70, 1 := 30 };}
    constraint valid_addr { address inside {[0:255]}; }
    constraint valid_data { write_data inside {[0:255]}; }
    



   endclass 
endpackage