package agent_wrapper;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    import driver_wrapper::*;
    import sequencer_wrapper::*;
    import config_wrapper::*;
    import monitor_wrapper::*;  // Assuming monitor_wrapper package exists; define if missing
    import sequence_wrapper_item::*;

    class SPI_Wrapper_agent extends uvm_agent;
        `uvm_component_utils(SPI_Wrapper_agent)
        
        SPI_Wrapper_driver driver;
        SPI_Wrapper_monitor monitor;  // FIXED: Use correct class name (assuming defined in monitor_wrapper)
        config_wrapper cfg;
        sequencer_wrapper seq_wrapper;

        uvm_analysis_port #(SPI_Wrapper_seq_item) agt_ap;  // FIXED: Use SPI_Wrapper_seq_item
        
        function new(string name = "SPI_Wrapper_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            if(!uvm_config_db#(config_wrapper)::get(this, "", "cfg", cfg))  // FIXED: Use "cfg" instead of "GFG"
                `uvm_fatal(get_type_name(), "Config object not found in agent class");

            seq_wrapper = sequencer_wrapper::type_id::create("seq_wrapper", this); 
            if (cfg.spi_agent_mode != UVM_PASSIVE) begin  // FIXED: Conditional based on config
                driver = SPI_Wrapper_driver::type_id::create("drv_wrapper", this);
            end
            monitor = SPI_Wrapper_monitor::type_id::create("monitor", this);  // FIXED: Create monitor always
            agt_ap = new("agt_ap", this);

        endfunction
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            if (driver != null) begin  // FIXED: Conditional connect
                driver.seq_item_port.connect(seq_wrapper.seq_item_export);
            end
            monitor.mon_ap.connect(agt_ap);  // FIXED: Use agt_ap (was agent_ap)

        endfunction
        
    endclass

endpackage

/*
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
        
        SPI_Wrapper_driver drv_wrapper;
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
            drv_wrapper = SPI_Wrapper_driver::type_id::create("drv_wrapper", this);
            monitor = SPI_Wrapper_monitor::type_id::create("monitor", this);
            agt_ap = new("agt_ap", this);

        endfunction
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

        drv_wrapper.if_wrapper = cfg.if_wrapper;
        monitor.if_wrapper = cfg.if_wrapper;
        monitor.mon_ap.connect(agt_ap);
        drv_wrapper.seq_item_port.connect(seq_wrapper.seq_item_export);

        endfunction
        
    endclass

endpackage
*/