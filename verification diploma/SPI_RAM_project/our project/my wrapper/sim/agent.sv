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
    uvm_analysis_port #(RAM_seq_item) agt_ap;
    
    // CHANGED: Default to PASSIVE for wrapper integration
    uvm_active_passive_enum is_active = UVM_PASSIVE;

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
        agt_ap = new("agt_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(RAM_config_obj)::get(this, "", "CFG", RAM_cfg))
            `uvm_fatal("build_phase", "Unable to get config object")
        
        // Always create monitor (for both active and passive)
        mon = monitor::type_id::create("mon", this);
        
        // ONLY create driver and sequencer if active
        if (is_active == UVM_ACTIVE) begin
            sqr = RAM_sequencer::type_id::create("sqr", this);
            drv = RAM_driver::type_id::create("drv", this);
            `uvm_info("BUILD", "RAM Agent configured as ACTIVE", UVM_LOW)
        end else begin
            `uvm_info("BUILD", "RAM Agent configured as PASSIVE", UVM_LOW)
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Always connect monitor
        mon.RAM_vif = RAM_cfg.RAM_vif;
        mon.mon_ap.connect(agt_ap);            
        
        // ONLY connect driver if active
        if (is_active == UVM_ACTIVE) begin
            drv.vif = RAM_cfg.RAM_vif;
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
    
    function void set_active(uvm_active_passive_enum mode);
        is_active = mode;
        `uvm_info("SET_ACTIVE", $sformatf("RAM Agent mode set to: %s", 
                  (mode == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE"), UVM_LOW)
    endfunction

endclass;
    
endpackage