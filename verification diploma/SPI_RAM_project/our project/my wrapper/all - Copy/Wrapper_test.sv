package test_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;

import env_wrapper::*;
import RAM_env_pkg::*;
import spi_slave_pkg::*;
import config_wrapper::*;
import RAM_config_pkg::*;
import sequence_wrapper_item::*;
import sequence_rst_wrapper::*;
import wrapper_sequence::*;
import read_only_sequence::*;
import write_only_sequence::*;
import write_read_sequence::*;


class SPI_Wrapper_test extends uvm_test;
    `uvm_component_utils(SPI_Wrapper_test)
    
    SPI_Wrapper_env env_wrapper;
    sequence_rst_wrapper seq_rst_wrapper;
    sequence_wrapper seq_wrapper;

    write_only_sequence write_seq;
    read_only_sequence read_seq;
    write_read_sequence write_read_seq;

    spi_slave_env env_slave;
    RAM_env env_ram;
    config_slave cfg_slave;
    config_wrapper cfg_wrapper;
    RAM_config_obj cfg_ram;



    function new(string name = "SPI_Wrapper_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

       // Create the environment
        env_wrapper = env_wrapper::type_id::create("env_wrapper", this);
        env_slave = env_slave::type_id::create("env_slave", this);
        env_ram = RAM_env::type_id::create("env_ram", this);

        // Create the configuration objects
        cfg_slave = config_slave::type_id::create("cfg_slave", this);
        cfg_wrapper = config_wrapper::type_id::create("cfg_wrapper", this);
        cfg_ram = RAM_config_obj::type_id::create("cfg_ram", this);

        seq_rst_wrapper = sequence_rst_wrapper::type_id::create("seq_rst_wrapper", this);
        seq_wrapper = sequence_wrapper::type_id::create("seq_wrapper", this);

        write_seq = write_only_sequence::type_id::create("write_seq", this);
        read_seq = read_only_sequence::type_id::create("read_seq", this);
        write_read_seq = write_read_sequence::type_id::create("write_read_seq", this);


        // get the configuration objects in the UVM config database
        if (!uvm_config_db#(virtual spi_slave_if)::get(this, "", "vif_slave", cfg_slave.vif)) begin
            `uvm_fatal("build_phase", "Config object not get in test class");
        end
        if (!uvm_config_db#(virtual interface_wrapper)::get(this, "", "vif", cfg_wrapper.if_wrapper)) begin
            `uvm_fatal("build_phase", "Config object not get in test class");
        end
        if (!uvm_config_db#(virtual RAM_vif)::get(this, "", "vif_ram", cfg_ram.if_ram)) begin
            `uvm_fatal("build_phase", "Config object not get in test class");
        end

        // Set the configuration objects in the database
        uvm_config_db#(config_slave)::set(this, "*", "GFG_slave", cfg_slave);
        uvm_config_db#(config_wrapper)::set(this, "*", "GFG", cfg_wrapper);
        uvm_config_db#(RAM_config_obj)::set(this, "*", "GFG_ram", cfg_ram);

    endfunction
    

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        
        seq_rst_wrapper.start(env_wrapperr.agt_wrapper.seq_wrapper);
        `uvm_info("run_phase", "Wrapper sequence started", UVM_MEDIUM)
        seq_wrapper.start(env_wrapperr.agt_wrapper.seq_wrapper);
        `uvm_info("run_phase", "Wrapper sequence started", UVM_MEDIUM)

        #10000;
        phase.drop_objection(this);
    endtask

endclass

endpackage