class SPI_Wrapper_agent extends uvm_agent;
    `uvm_component_utils(SPI_Wrapper_agent)
    
    SPI_Wrapper_driver driver;
    SPI_Wrapper_monitor monitor;
    uvm_sequencer #(SPI_Wrapper_seq_item) sequencer;
    
    uvm_analysis_port #(SPI_Wrapper_seq_item) agt_ap;
    
    function new(string name = "SPI_Wrapper_agent", uvm_component parent = null);
        super.new(name, parent);
        agt_ap = new("agt_ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        monitor = SPI_Wrapper_monitor::type_id::create("monitor", this);
        
        // Build driver and sequencer only if active
        if (get_is_active() == UVM_ACTIVE) begin
            driver = SPI_Wrapper_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(SPI_Wrapper_seq_item)::type_id::create("sequencer", this);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to agent analysis port
        monitor.mon_ap.connect(agt_ap);
        
        // Connect driver to sequencer if active
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass