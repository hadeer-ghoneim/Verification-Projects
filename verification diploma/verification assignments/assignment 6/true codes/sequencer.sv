package sequencer_pkg;
import uvm_pkg::*;
import sequenceItem_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name, this);

class sequencer extends uvm_sequencer #(ALSU_sequenceItem);
    `uvm_component_utils(sequencer)
    function new(string name = "sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction 
endclass 
endpackage