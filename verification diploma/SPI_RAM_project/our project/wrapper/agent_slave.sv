// agent_slave.sv
package agent_slave;
`include "uvm_macros.svh"
import uvm_pkg::*;
import config_slave::*;
import sequencer_slave::*;
import driver_slave::*;
import monitor_slave::*;
import sequence_slave_item::*;

class agent_slave extends uvm_agent;
    `uvm_component_utils(agent_slave)

    config_slave cfg;
    sequencer_slave seq_slave;
    driver_slave drv_slave;
    monitor_slave mon_slave;
    bit is_passive = 1;
    uvm_analysis_port#(sequence_slave_item) agent_cov_ap;

    function new(string name = "agent_slave", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       
        // Get configuration object
        if(!uvm_config_db#(config_slave)::get(this, "", "GFG_slave", cfg)) begin
            `uvm_fatal("build_phase", "Config object not get in agent class")
        end

        // Create components based on active/passive mode
        if(cfg.is_passive == UVM_ACTIVE) begin  // Fixed: use UVM_ACTIVE
            seq_slave = sequencer_slave::type_id::create("seq_slave", this);
            drv_slave = driver_slave::type_id::create("drv_slave", this);
        end     
        
        mon_slave = monitor_slave::type_id::create("mon_slave", this);
        agent_cov_ap = new("agent_cov_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
       
        // Connect analysis port
        mon_slave.mon_ap.connect(agent_cov_ap);
        
        // Connect sequencer to driver if active
        if(cfg.is_passive == UVM_ACTIVE) begin
            drv_slave.seq_item_port.connect(seq_slave.seq_item_export);
        end
    endfunction    
endclass

endpackage