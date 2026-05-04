class SPI_Wrapper_driver extends uvm_driver #(SPI_Wrapper_seq_item);
    `uvm_component_utils(SPI_Wrapper_driver)
    
    virtual SPI_Wrapper_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual SPI_Wrapper_if)::get(this, "", "SPI_Wrapper_vif", vif))
            `uvm_fatal("NOCFG", "SPI_Wrapper interface not found")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // Initialize signals
        vif.driver_cb.rst_n <= 1;
        vif.driver_cb.SS_n <= 1;
        vif.driver_cb.MOSI <= 0;
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(SPI_Wrapper_seq_item item);
        int active_cycles = item.get_spi_cycles();
        
        `uvm_info("DRIVER", $sformatf("Driving: %s", item.convert2string()), UVM_MEDIUM)
        
        // Handle reset
        if (!item.rst_n) begin
            vif.driver_cb.rst_n <= 0;
            repeat(3) @(vif.driver_cb);
            vif.driver_cb.rst_n <= 1;
            @(vif.driver_cb);
            return;
        end
        
        // Start SPI transaction
        vif.driver_cb.SS_n <= 0;
        
        // Send 11-bit SPI frame
        for (int i = 10; i >= 0; i--) begin
            vif.driver_cb.MOSI <= item.spi_frame[i];
            @(vif.driver_cb);
        end
        
        // Extended cycles for read data operation
        if (item.operation == READ_DATA) begin
            repeat(10) @(vif.driver_cb);
        end else begin
            @(vif.driver_cb);
        end
        
        // End transaction
        vif.driver_cb.SS_n <= 1;
        repeat(2) @(vif.driver_cb);
    endtask
endclass