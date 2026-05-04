package config_slave;
`include "uvm_macros.svh"
import uvm_pkg::*;

class config_slave extends uvm_object;
    `uvm_object_utils(config_slave)

    // Use consistent naming - vif_slave instead of if_slave
    virtual interface_slave vif_slave;
    uvm_active_passive_enum is_passive = UVM_PASSIVE;

    function new(string name = "config_slave");
        super.new(name);
    endfunction
endclass

endpackage