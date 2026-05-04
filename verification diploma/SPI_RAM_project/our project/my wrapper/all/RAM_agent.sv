package agent_pkg;

import uvm_pkg::*;
import RAM_config_pkg::*;
import RAM_seq_item_pkg::*;
import RAM_driver_pkg::*;
import RAM_sequencer_pkg::*;
import monitor_pkg::*;

`include "uvm_macros.svh"

class agent extends uvm_agent;
 `uvm_component_utils(agent)

    RAM_config_obj RAM_cfg;
    RAM_driver drv;
    monitor mon;
    RAM_sequencer sqr;

    bit is_passive = 1 ; // Default to passive
    
    uvm_analysis_port #(RAM_seq_item) agt_ap;
    

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(RAM_config_obj)::get(this, "", "CFG", RAM_cfg)) begin
            `uvm_fatal("build_phase", "Unable to get config object")
        end
      
        if (RAM_cfg.is_passive == UVM_PASSIVE) begin

            sqr = RAM_sequencer::type_id::create("sqr", this);
            drv = RAM_driver::type_id::create("drv", this); 
        end 

        // Always create monitor (for both active and passive)
        mon = monitor::type_id::create("mon", this);
        agt_ap = new("agt_ap", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        drv.if_ram = RAM_cfg.if_ram;
        mon.if_ram = RAM_cfg.if_ram;
        mon.mon_ap.connect(agt_ap);
        drv.seq_item_port.connect(sqr.seq_item_export);
        
    endfunction

endclass;
    
endpackage