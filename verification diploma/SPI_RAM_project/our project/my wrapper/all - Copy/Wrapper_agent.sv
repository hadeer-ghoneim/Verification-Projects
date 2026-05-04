package agent_wrapper;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    import driver_wrapper::*;
    import sequencer_wrapper::*;
    import config_wrapper::*;
    import monitor_wrapper::*;
    import sequence_wrapper_item::*;

    class SPI_Wrapper_agent extends uvm_agent;
        `uvm_component_utils(SPI_Wrapper_agent)
        
        SPI_Wrapper_driver driver;
        SPI_Wrapper_monitor monitor;
        config_wrapper cfg;
        sequencer_wrapper seq_wrapper;

        uvm_analysis_port #(SPI_Wrapper_seq_item) agt_ap;
        
        function new(string name = "SPI_Wrapper_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            if(!uvm_config_db#(config_wrapper)::get(this, "", "GFG", cfg))begin
                    `uvm_fatal("build_phase", "Config object not get in agent class")
            end

            seq_wrapper = sequencer_wrapper::type_id::create("seq_wrapper", this); 
            driver = SPI_Wrapper_driver::type_id::create("drv_wrapper", this);
            monitor = SPI_Wrapper_monitor::type_id::create("monitor", this);
            agt_ap = new("agt_ap", this);

        endfunction
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

        drv_wrapper.if_wrapper = cfg.if_wrapper;
        monitor.if_wrapper = cfg.if_wrapper;
        monitor.mon_ap.connect(agent_ap);
        driver.seq_item_port.connect(seq_wrapper.seq_item_export);

        endfunction
        
    endclass

endpackage