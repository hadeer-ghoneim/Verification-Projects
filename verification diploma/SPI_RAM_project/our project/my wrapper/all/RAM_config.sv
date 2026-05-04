package RAM_config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_config_obj extends uvm_object;
    `uvm_object_utils(RAM_config_obj)
    
    virtual RAM_if if_ram;
  
    uvm_active_passive_enum is_passive = UVM_PASSIVE; // Default to passive agent

    
    function new(string name ="RAM_config_obj");
        super.new(name);
    endfunction

endclass
endpackage