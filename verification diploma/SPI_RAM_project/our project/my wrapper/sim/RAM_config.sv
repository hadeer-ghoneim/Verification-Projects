package RAM_config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_config_obj extends uvm_object;
    `uvm_object_utils(RAM_config_obj)
    
    virtual RAM_vif RAM_vif;
    uvm_active_passive_enum agent_mode = UVM_PASSIVE;
    
    function new(string name ="RAM_config_obj");
        super.new(name);
    endfunction

endclass
endpackage