class SPI_Wrapper_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_Wrapper_monitor)
    
    virtual SPI_Wrapper_if vif;
    uvm_analysis_port #(SPI_Wrapper_seq_item) mon_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual SPI_Wrapper_if)::get(this, "", "SPI_Wrapper_vif", vif))
            `uvm_fatal("NOCFG", "SPI_Wrapper interface not found")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        SPI_Wrapper_seq_item item;
        
        forever begin
            @(vif.monitor_cb);
            
            item = SPI_Wrapper_seq_item::type_id::create("item");
            
            // Capture all signals
            item.rst_n = vif.rst_n;
            item.read_data = vif.tx_data; // Data read from RAM
            
            // Capture when rx_valid is high (complete transaction)
            if (vif.rx_valid) begin
                item.operation = SPI_Wrapper_seq_item::op_type_e'(vif.rx_data[9:8]);
                case(item.operation)
                    SET_ADDR:  item.address = vif.rx_data[7:0];
                    WRITE:     item.data = vif.rx_data[7:0];
                    READ_ADDR: item.address = vif.rx_data[7:0];
                    READ_DATA: item.data = 8'h00;
                endcase
                
                `uvm_info("MONITOR", $sformatf("Captured: %s", item.convert2string()), UVM_HIGH)
                mon_ap.write(item);
            end
        end
    endtask
endclass