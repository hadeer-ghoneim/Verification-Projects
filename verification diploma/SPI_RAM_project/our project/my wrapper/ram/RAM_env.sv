package RAM_env_pkg;

import uvm_pkg::*;
import RAM_coverage_pkg::*;
import RAM_scoreboard_pkg::*;
import agent_pkg::*;
import RAM_seq_item_pkg::*;  // NEW: Import seq_item package

`include "uvm_macros.svh"

class RAM_env extends uvm_env;
    `uvm_component_utils(RAM_env)

    agent agt;
    RAM_scoreboard sb;
    RAM_coverage cov;
    
    // NEW: Analysis port for wrapper integration - using RAM_seq_item type
    uvm_analysis_port #(RAM_seq_item) ram_tx_ap;

    function new(string name = "RAM_env", uvm_component parent = null);  
        super.new(name, parent);
        ram_tx_ap = new("ram_tx_ap", this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt = agent::type_id::create("agt", this);
        sb = RAM_scoreboard::type_id::create("sb", this);
        cov = RAM_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect agent analysis port to scoreboard and coverage
        agt.agt_ap.connect(sb.sb_export);
        agt.agt_ap.connect(cov.cov_export);
        
        // NEW: Connect to wrapper analysis port
        agt.agt_ap.connect(ram_tx_ap);
    endfunction
    
    // NEW: Function to set passive mode for wrapper
    function void set_passive_mode();
        agt.set_active(UVM_PASSIVE);
    endfunction
endclass
endpackage