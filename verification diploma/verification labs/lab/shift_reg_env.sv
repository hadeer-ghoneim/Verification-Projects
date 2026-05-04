
package shift_reg_env_pkg;
import shift_reg_agent_pkg::*;
import shift_reg_scoreboard_pkg::*;
import shift_reg_cvr_pkg::*;
import shift_reg_sequencer_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class shift_reg_env extends uvm_env;
  // Example 1
  // Do the essentials (factory register & Constructor)
  `uvm_component_utils(shift_reg_env) 

  shift_reg_agent agt ;
  shift_reg_scoreboard sb ;
  shift_reg_cvr cvr ;
  function new (string name = "shift_reg_env" , uvm_component parent = null);
    super.new(name , parent) ;
  endfunction


  // Example 2
  // Build the driver in the build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;
    agt = shift_reg_agent::type_id::create("agt",this) ;
    sb = shift_reg_scoreboard::type_id::create("sb",this) ;
    cvr = shift_reg_cvr::type_id::create("cvr",this) ;
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase) ;
    agt.agt_ap.connect(sb.sb_export) ;
    agt.agt_ap.connect(cvr.cvr_export);
  endfunction
endclass
endpackage