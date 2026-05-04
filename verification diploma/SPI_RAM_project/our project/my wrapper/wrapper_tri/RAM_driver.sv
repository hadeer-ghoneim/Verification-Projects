package RAM_driver_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import RAM_seq_item_pkg::*;
import RAM_config_pkg::*;

class RAM_driver extends uvm_driver #(RAM_seq_item);
    `uvm_component_utils(RAM_driver)

    virtual RAM_if if_ram;
    RAM_seq_item item;
    
    function new(string name = "RAM_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        super.run_phase(phase);

       // Generate valid transactions here
        if_ram.rst_n =item.rst_n;
        if_ram.rx_valid = item.rx_valid;
        if_ram.din = item.din;
         @(negedge if_ram.clk);
        seq_item_port.item_done();

    endtask


endclass
endpackage