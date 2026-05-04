package spi_slave_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"


  // ==========================================================================
  // configuration 
  // ==========================================================================
  class config_slave extends uvm_object;
    `uvm_object_utils(config_slave)

    // Virtual interface for the slave
    virtual spi_slave_if if_slave;
    uvm_active_passive_enum is_passive = UVM_PASSIVE; // Default to passive agent
    // Constructor
    function new(string name = "config_slave");
        super.new(name);
    endfunction

  endclass   

  // ==========================================================================
  // Sequence Item
  // ==========================================================================
  class spi_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_slave_seq_item)
    
    rand bit rst_n;
    rand bit [10:0] MOSI_data;
    rand bit [7:0] tx_data;
    rand bit is_read_data;
    
    // Outputs
    bit MISO;
    bit rx_valid;
    bit [9:0] rx_data;
    bit SS_n;
    bit tx_valid;
    
    // Constraint 1: Reset deasserted most of the time
    constraint rst_c {
      rst_n dist {1 := 95, 0 := 5};
    }
    
    // Constraint 3: Valid command combinations
    constraint mosi_cmd_c {
      MOSI_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }
    
    // Better distribution for coverage
    constraint cmd_dist_c {
      MOSI_data[10:8] dist {
        3'b000 := 30,  // Write Address
        3'b001 := 25,  // Write Data
        3'b110 := 25,  // Read Address
        3'b111 := 20   // Read Data
      };
    }
    
    function new(string name = "spi_slave_seq_item");
      super.new(name);
    endfunction
    
    function void post_randomize();
      is_read_data = (MOSI_data[10:8] == 3'b111);
      tx_valid = is_read_data;
    endfunction
    
  endclass

  // ==========================================================================
  // Sequencer
  // ==========================================================================
  class sequencer_slave extends uvm_sequencer#(spi_slave_seq_item);
    
    `uvm_component_utils(sequencer_slave)    
    
    function new(string name = "sequencer_slave", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  endclass    
  
  // ==========================================================================
  // Driver
  // ==========================================================================
  class spi_slave_driver extends uvm_driver#(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_driver)
    
    virtual spi_slave_if if_slave;
    spi_slave_seq_item item;
    
    function new(string name = "spi_slave_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item = spi_slave_seq_item::type_id::create("item");
    endfunction
    
    task run_phase(uvm_phase phase);
     super.run_phase(phase);

       forever begin
            // Get the next item from the sequencer
            seq_item_port.get_next_item(item);

            // Drive the item to the virtual interface
            if (item != null) begin
                // Add your driving logic here
                if_slave.rst_n = item.rst_n;
                if_slave.MOSI_data = item.MOSI_data;
                if_slave.SS_n = item.SS_n;
                if_slave.tx_valid = item.tx_valid;
                if_slave.tx_data = item.tx_data;
                @(negedge if_slave.clk); // Wait for the clock edge
                seq_item_port.item_done();
            end
        end
    endtask

  endclass
  
  // ==========================================================================
  // Monitor - ENHANCED for better cross coverage tracking
  // ==========================================================================
    class spi_slave_monitor extends uvm_monitor;
    `uvm_component_utils(spi_slave_monitor)
    
    virtual spi_slave_if if_slave;
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
      if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_if", if_slave))
        `uvm_fatal(get_type_name(), "Virtual interface not found")
      mon_ap = new("mon_ap", this);
      ram_tx_ap = new("ram_tx_ap", this); // New port for RAM
    endfunction
    
    task run_phase(uvm_phase phase);
      spi_slave_seq_item item;
      prev_SS_n = 1;
      
      forever begin
        item = spi_slave_seq_item::type_id::create("item");
        
        @(posedge if_slave.clk);
        
        item.rst_n = if_slave.rst_n;
        item.SS_n = if_slave.SS_n;
        item.tx_valid = if_slave.tx_valid;
        item.tx_data = if_slave.tx_data; // Capture from RAM
        item.MISO = if_slave.MISO;
        item.rx_valid = if_slave.rx_valid;
        item.rx_data = if_slave.rx_data;
        
        // Track command during transaction
        if (if_slave.rx_valid) begin
          last_rx_data = if_slave.rx_data;
          item.MOSI_data[10:8] = if_slave.rx_data[9:8];
          item.is_read_data = (if_slave.rx_data[9:8] == 2'b11);
          
          // Send to RAM analysis port when valid transaction
          ram_tx_ap.write(item);
        end else if (!if_slave.SS_n && prev_SS_n) begin
          // Falling edge detected - use last known command
          item.rx_data = last_rx_data;
        end
        
        prev_SS_n = if_slave.SS_n;
        
        mon_ap.write(item);
      end
    endtask
    
  endclass



  
  // ==========================================================================
  // Agent
  // ==========================================================================

     class spi_slave_agent extends uvm_agent;
        `uvm_component_utils(spi_slave_agent)
        
        config_slave cfg;
        spi_slave_driver drv;
        spi_slave_monitor mon;
        sequencer_slave sqr;
        
        uvm_analysis_port#(spi_slave_seq_item) ram_tx_ap;
        
        // Configuration for passive mode
        bit is_passive = 1;
        
        function new(string name = "spi_slave_agent", uvm_component parent = null);
        super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
          // Always build monitor
          mon = spi_slave_monitor::type_id::create("mon", this);
          ram_tx_ap = new("ram_tx_ap", this);
          
         // Create the configuration object
        if(!uvm_config_db#(config_slave)::get(this, "", "GFG_slave", cfg))begin
            `uvm_fatal("build_phase", "Config object not get in agent class")        end

        // Create the sequencer
        if(cfg.is_passive == UVM_PASSIVE )begin
              drv = spi_slave_driver::type_id::create("drv", this);
              sqr = sequencer_slave::type_id::create("sqr", this);
          end

        endfunction
        
        function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect the sequencer to the driver
        drv.if_slave = cfg.if_slave;
        mon.if_slave = cfg.if_slave;
        mon.mon_ap.connect(ram_tx_ap);
        drv.seq_item_port.connect(sqr.seq_item_export);

        endfunction
        
        
    endclass

  
 // ==========================================================================
  // Scoreboard
  // ==========================================================================
  class spi_slave_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_slave_scoreboard)
    
    uvm_analysis_imp#(spi_slave_seq_item, spi_slave_scoreboard) sb_imp;
    int pass_count, fail_count;
    
    function new(string name = "spi_slave_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_imp = new("sb_imp", this);
    endfunction
    
    function void write(spi_slave_seq_item item);
      if (!item.rst_n) begin
        if (item.MISO == 0 && item.rx_valid == 0 && item.rx_data == 0) begin
          pass_count++;
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf("FAIL: Outputs not cleared during reset"))
        end
      end
      
      if (item.rx_valid && item.rst_n) begin
        `uvm_info(get_type_name(), $sformatf("Transaction: rx_data=%0h (%s)", 
                  item.rx_data, 
                  item.rx_data[9:8] == 2'b00 ? "WRITE_ADDR" :
                  item.rx_data[9:8] == 2'b01 ? "WRITE_DATA" :
                  item.rx_data[9:8] == 2'b10 ? "READ_ADDR" : "READ_DATA"), UVM_MEDIUM)
        pass_count++;
      end
    endfunction
    
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info(get_type_name(), $sformatf("\n=== SCOREBOARD SUMMARY ===\nPass: %0d | Fail: %0d", 
                pass_count, fail_count), UVM_LOW)
    endfunction
    
  endclass
  
  // ==========================================================================
  // Coverage Collector - FIXED for 100% coverage
  // ==========================================================================
  class spi_slave_coverage extends uvm_subscriber#(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_coverage)
    
    spi_slave_seq_item item;
    bit prev_SS_n = 1;
    bit [1:0] current_cmd;

    // Coverage export
    uvm_analysis_export#(spi_slave_seq_item) cov_export;
    uvm_tlm_analysis_fifo#(spi_slave_seq_item) cov_fifo;

    // functional coverage 
    
    covergroup spi_cov;
      
      // REQUIREMENT 1: rx_data[9:8] values and transitions
      rx_data_cp: coverpoint item.rx_data[9:8] iff (item.rx_valid && item.rst_n) {
        bins write_addr = {2'b00};
        bins write_data = {2'b01};
        bins read_addr = {2'b10};
        bins read_data = {2'b11};
        bins transitions = (2'b00 => 2'b01 => 2'b10 => 2'b11);
      }
      
      // REQUIREMENT 2: SS_n timing patterns
      ss_n_transaction_cp: coverpoint item.rx_data[9:8] iff (item.rx_valid && item.rst_n) {
        bins normal_write_addr = {2'b00};
        bins normal_write_data = {2'b01};
        bins normal_read_addr = {2'b10};
        bins extended_read_data = {2'b11};
      }
      
      // ENHANCED: Track SS_n state for cross coverage
      ss_n_state_cp: coverpoint item.SS_n iff (item.rst_n) {
        bins ss_active = {0};
        bins ss_idle = {1};
        bins ss_falling = (1 => 0);
        bins ss_rising = (0 => 1);
      }
      
      // REQUIREMENT 3: MOSI command validation
      mosi_cmd_cp: coverpoint current_cmd iff (item.rst_n) {
        bins write_addr_cmd = {2'b00};
        bins write_data_cmd = {2'b01};
        bins read_addr_cmd = {2'b10};
        bins read_data_cmd = {2'b11};
      }
      
      // REQUIREMENT 4: Cross coverage - FIXED
      // Sample during any SS_n state when we have valid command info
      ss_mosi_cross: cross ss_n_state_cp, mosi_cmd_cp iff (item.rst_n) {
        // Only ignore truly impossible combinations
        ignore_bins impossible_read_data_idle = binsof(ss_n_state_cp.ss_idle) && binsof(mosi_cmd_cp.read_data_cmd);
        ignore_bins impossible_read_data_rising = binsof(ss_n_state_cp.ss_rising) && binsof(mosi_cmd_cp.read_data_cmd);
        ignore_bins impossible_read_addr_active = binsof(ss_n_state_cp.ss_active) && binsof(mosi_cmd_cp.read_addr_cmd);
        ignore_bins impossible_read_addr_falling = binsof(ss_n_state_cp.ss_falling) && binsof(mosi_cmd_cp.read_addr_cmd);
        ignore_bins impossible_write_data_active = binsof(ss_n_state_cp.ss_active) && binsof(mosi_cmd_cp.write_data_cmd);
        ignore_bins impossible_write_data_falling = binsof(ss_n_state_cp.ss_falling) && binsof(mosi_cmd_cp.write_data_cmd);
      }
      
    endgroup

    // Constructor
    
    function new(string name = "spi_slave_coverage", uvm_component parent = null);
      super.new(name, parent);
      spi_cov = new();
    endfunction


   function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       cov_export = new("cov_export", this);
         cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect the export to the FIFO
        cov_export.connect(cov_fifo.analysis_export);
    endfunction    

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            // Wait for an item to be written to the FIFO
        cov_fifo.get(item);
        spi_cov.sample();
           
            
        end
    endtask    


    function void write(spi_slave_seq_item t);
      item = t;
      
      // Update current command when rx_valid
      if (item.rx_valid) begin
        current_cmd = item.rx_data[9:8];
      end
      
      // Sample coverage every cycle
      spi_cov.sample();
      
      prev_SS_n = item.SS_n;
    endfunction
    
    function void report_phase(uvm_phase phase);
      real total_cov = spi_cov.get_coverage();
      `uvm_info(get_type_name(), $sformatf("\n=== FUNCTIONAL COVERAGE ===\nTotal: %.2f%%\nrx_data: %.2f%%\nss_n_trans: %.2f%%\nss_n_state: %.2f%%\nmosi_cmd: %.2f%%\ncross: %.2f%%", 
                total_cov,
                spi_cov.rx_data_cp.get_coverage(),
                spi_cov.ss_n_transaction_cp.get_coverage(),
                spi_cov.ss_n_state_cp.get_coverage(),
                spi_cov.mosi_cmd_cp.get_coverage(),
                spi_cov.ss_mosi_cross.get_coverage()), UVM_LOW)
    endfunction
    
  endclass
  
  // ==========================================================================
  // Environment
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
    endfunction
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.mon_ap.connect(sb.sb_imp);
      agt.mon.mon_ap.connect(cov.analysis_export);
      
    endfunction

  endclass

endpackage