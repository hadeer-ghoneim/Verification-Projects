  // ==========================================================================
  // Monitor - UPDATED for wrapper integration
  // ==========================================================================
  class spi_slave_monitor extends uvm_monitor;
    `uvm_component_utils(spi_slave_monitor)
    
    virtual spi_slave_if vif;
    uvm_analysis_port#(spi_slave_seq_item) mon_ap;
    bit prev_SS_n;
    bit [9:0] last_rx_data;
    
    // New analysis port for RAM transactions
    uvm_analysis_port#(spi_slave_seq_item) ram_tx_ap;
    
    function new(string name = "spi_slave_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface not found")
      mon_ap = new("mon_ap", this);
      ram_tx_ap = new("ram_tx_ap", this); // New port for RAM
    endfunction
    
    task run_phase(uvm_phase phase);
      spi_slave_seq_item item;
      prev_SS_n = 1;
      
      forever begin
        item = spi_slave_seq_item::type_id::create("item");
        
        @(posedge vif.clk);
        
        item.rst_n = vif.rst_n;
        item.SS_n = vif.SS_n;
        item.tx_valid = vif.tx_valid;
        item.tx_data = vif.tx_data; // Capture from RAM
        item.MISO = vif.MISO;
        item.rx_valid = vif.rx_valid;
        item.rx_data = vif.rx_data;
        
        // Track command during transaction
        if (vif.rx_valid) begin
          last_rx_data = vif.rx_data;
          item.MOSI_data[10:8] = vif.rx_data[9:8];
          item.is_read_data = (vif.rx_data[9:8] == 2'b11);
          
          // Send to RAM analysis port when valid transaction
          ram_tx_ap.write(item);
        end else if (!vif.SS_n && prev_SS_n) begin
          // Falling edge detected - use last known command
          item.rx_data = last_rx_data;
        end
        
        prev_SS_n = vif.SS_n;
        
        mon_ap.write(item);
      end
    endtask
    
  endclass

endpackage