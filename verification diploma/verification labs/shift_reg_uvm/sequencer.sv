package sequencer_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import shift_reg_seq_item_pkg::*;
import shared_pkg::*;

class sequencer extends uvm_sequencer #(shift_reg_seq_item);
    `uvm_component_utils(sequencer)

    function new(string name = "sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass

endpackage
