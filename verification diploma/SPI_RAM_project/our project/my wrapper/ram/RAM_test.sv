package RAM_test_pkg;
import RAM_env_pkg::*;
import RAM_config_pkg::*;
import reset_sequence_pkg::*;
import write_only_sequence_pkg::*;
import read_only_sequence_pkg::*;
import write_read_sequence_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_test extends uvm_test;
    `uvm_component_utils(RAM_test)

    RAM_env env;
    RAM_config_obj RAM_cfg;
    virtual RAM_vif RAM_vif;
    RAM_reset_sequence reset_seq;
    RAM_write_only_sequence write_seq; 
    RAM_read_only_sequence read_seq;
    RAM_write_read_sequence write_read_seq;

    function new(string name = "RAM_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = RAM_env::type_id::create("env", this);
        RAM_cfg = RAM_config_obj::type_id::create("RAM_cfg");
        
        // FIXED: Get virtual interface correctly
        if(!uvm_config_db #(virtual RAM_vif)::get(this, "", "RAM_VIF", RAM_vif))
            `uvm_fatal("build phase", "Unable to get Virtual Interface");
        
        RAM_cfg.RAM_vif = RAM_vif;
        uvm_config_db #(RAM_config_obj)::set(this, "*", "CFG", RAM_cfg);
        
        // Create sequences
        reset_seq = RAM_reset_sequence::type_id::create("reset_seq");
        write_seq = RAM_write_only_sequence::type_id::create("write_seq");
        read_seq = RAM_read_only_sequence::type_id::create("read_seq");
        write_read_seq = RAM_write_read_sequence::type_id::create("write_read_seq");
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        
        `uvm_info("RUN_PHASE", "Starting RAM Test Sequence", UVM_LOW);
        
        // Apply reset
        `uvm_info("RUN_PHASE", "Applying reset...", UVM_MEDIUM);
        reset_seq.start(env.agt.sqr);
        
        // Run test sequences (uncomment as needed)
        `uvm_info("RUN_PHASE", "Running write-read sequence...", UVM_MEDIUM);
        write_read_seq.start(env.agt.sqr);
        
        `uvm_info("RUN_PHASE", "RAM test completed", UVM_MEDIUM);
        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (env.sb.fail_count == 0) begin
            `uvm_info("TEST_RESULT", "*** RAM TEST PASSED ***", UVM_NONE)
        end else begin
            `uvm_info("TEST_RESULT", "*** RAM TEST FAILED ***", UVM_NONE)
        end
    endfunction

endclass: RAM_test
endpackage