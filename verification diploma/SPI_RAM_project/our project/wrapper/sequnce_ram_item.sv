package sequnce_ram_item;
import uvm_pkg::*;
`include "uvm_macros.svh"

class sequnce_ram_item extends uvm_sequence_item;
    
    `uvm_object_utils(sequnce_ram_item)
    
    rand bit [9:0] datain;
    rand bit rx_valid, rst_n;
    logic [7:0] dout, dout_ref;
    logic tx_valid, tx_valid_ref;
    
    function new(string name = "sequnce_ram_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "rst_n=%0b, rx_valid=%b, datain=%0b, dout=%b, tx_valid=%b, dout_ref=%b, tx_valid_ref=%b", 
            rst_n, rx_valid, datain, dout, tx_valid, dout_ref, tx_valid_ref 
        );
    endfunction

    function string convert2string_stimulus();
        return $sformatf(
            "rst_n=%0b, rx_valid=%b, datain=%0b",
            rst_n, rx_valid, datain
        );
    endfunction

    constraint c_reset_low_prob { 
        rst_n dist { 0 := 5, 1 := 95 };
    }
    
    constraint c_rx_valid_low_prob { 
        rx_valid dist { 0 := 5, 1 := 95 };
    }

endclass 

endpackage