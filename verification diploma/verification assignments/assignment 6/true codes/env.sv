package env_pkg;
import shared_pkg::*;
import scoreboard_pkg::*;
import coverage_collector_pkg::*;
import agent_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name, this);

class ALSU_env extends uvm_env;
    `uvm_component_utils(ALSU_env)

    ALSU_scoreboard sb;
    ALSU_coverage cov;
    ALSU_agent agt;

    function new(string name = "ALSU_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

 
        agt = `create_obj(ALSU_agent, "agt")
        sb = `create_obj(ALSU_scoreboard, "sb")
        cov = `create_obj(ALSU_coverage, "cov")

   
    endfunction

    function void connect_phase(uvm_phase phase);     
        agt.agt_port.connect(sb.sb_export);   
        agt.agt_port.connect(cov.cov_export);  
    endfunction
endclass
endpackage