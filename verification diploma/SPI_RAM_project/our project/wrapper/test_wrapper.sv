// test_wrapper.sv
package test_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import env_wrapper::*;
import env_slave::*;
import env_ram::*;
import config_slave::*;
import config_wrapper::*;
import config_ram::*;
import sequence_wrapper_item::*;
import sequence_rst_wrapper::*;
import sequence_wrapper::*;

class test_wrapper extends uvm_test;
    `uvm_component_utils(test_wrapper)
    env_wrapper env_wrapperr;
    env_slave env_slaver;
    env_ram env_ramm;
    config_slave cfg_slave;
    config_wrapper cfg_wrapper;
    config_ram cfg_ram;
    sequence_rst_wrapper seq_rst_wrapper;
    sequence_wrapper seq_wrapper;

    function new(string name = "test_wrapper", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);   
        
        // Create the environment
        env_wrapperr = env_wrapper::type_id::create("env_wrapperr", this);
        env_slaver = env_slave::type_id::create("env_slaver", this);
        env_ramm = env_ram::type_id::create("env_ramm", this);

        // Create the configuration objects
        cfg_slave = config_slave::type_id::create("cfg_slave", this);
        cfg_wrapper = config_wrapper::type_id::create("cfg_wrapper", this);
        cfg_ram = config_ram::type_id::create("cfg_ram", this);

        seq_rst_wrapper = sequence_rst_wrapper::type_id::create("seq_rst_wrapper", this);
        seq_wrapper = sequence_wrapper::type_id::create("seq_wrapper", this);

        // Get the virtual interfaces from config DB
        if (!uvm_config_db#(virtual interface_slave)::get(this, "", "vif_slave", cfg_slave.vif_slave)) begin
            `uvm_fatal("build_phase", "vif_slave not found in test class");
        end
        if (!uvm_config_db#(virtual interface_wrapper)::get(this, "", "vif", cfg_wrapper.if_wrapper)) begin
            `uvm_fatal("build_phase", "vif not found in test class");
        end
        if (!uvm_config_db#(virtual interface_ram)::get(this, "", "vif_ram", cfg_ram.if_ram)) begin
            `uvm_fatal("build_phase", "vif_ram not found in test class");
        end
        
        // Set the configuration objects in the database
        uvm_config_db#(config_slave)::set(this, "*", "GFG_slave", cfg_slave);
        uvm_config_db#(config_wrapper)::set(this, "*", "GFG", cfg_wrapper);
        uvm_config_db#(config_ram)::set(this, "*", "GFG_ram", cfg_ram);

        // ALSO set virtual interface directly for monitor as backup
        uvm_config_db#(virtual interface_slave)::set(this, "env_slaver.agt_slave.mon_slave", "vif_slave", cfg_slave.vif_slave);
        
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);

        `uvm_info("run_phase", "Starting sequences", UVM_LOW)
        
        seq_rst_wrapper.start(env_wrapperr.agt_wrapper.seq_wrapper);
        `uvm_info("run_phase", "Reset sequence started", UVM_MEDIUM)
        
        seq_wrapper.start(env_wrapperr.agt_wrapper.seq_wrapper);
        `uvm_info("run_phase", "Main sequence started", UVM_MEDIUM)

        // Wait for some time to see monitor output
        #10000;
        
        phase.drop_objection(this);
    endtask

endclass

endpackage