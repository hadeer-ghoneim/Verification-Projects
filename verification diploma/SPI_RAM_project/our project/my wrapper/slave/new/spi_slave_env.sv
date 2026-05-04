  // ==========================================================================
  // Environment - UPDATED for wrapper integration
  // ==========================================================================
  class spi_slave_env extends uvm_env;
    `uvm_component_utils(spi_slave_env)
    
    spi_slave_agent agt;
    spi_slave_scoreboard sb;
    spi_slave_coverage cov;
    
    uvm_analysis_port#(spi_slave_seq_item) ram_tx_ap;
    
    function new(string name = "spi_slave_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt = spi_slave_agent::type_id::create("agt", this);
      sb = spi_slave_scoreboard::type_id::create("sb", this);
      cov = spi_slave_coverage::type_id::create("cov", this);
      ram_tx_ap = new("ram_tx_ap", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.mon_ap.connect(sb.sb_imp);
      agt.mon.mon_ap.connect(cov.analysis_export);
      
      // Connect agent's RAM port to environment's RAM port
      agt.ram_tx_ap.connect(ram_tx_ap);
    endfunction
    
    // Function to set passive mode
    function void set_passive_mode(bit passive);
      agt.set_passive(passive);
    endfunction
    
  endclass

endpackage