package env_wrapper;
import uvm_pkg::*;
`include "uvm_macros.svh"

import agent_wrapper::*;
import scoreboard_wrapper::*;
import coverage_wrapper::*;

class SPI_Wrapper_env extends uvm_env;
    `uvm_component_utils(SPI_Wrapper_env)
    
    SPI_Wrapper_agent agt;
    SPI_Wrapper_scoreboard sb;
    SPI_Wrapper_coverage cov;
    
    function new(string name = "SPI_Wrapper_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Build main SPI Wrapper components
        agt = SPI_Wrapper_agent::type_id::create("agt", this);
        sb = SPI_Wrapper_scoreboard::type_id::create("sb", this);
        cov = SPI_Wrapper_coverage::type_id::create("cov", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect main agent to scoreboard and coverage
        agt.agt_ap.connect(sb.sb_imp);
        agt.agt_ap.connect(cov.analysis_export);

    endfunction
endclass

endpackage