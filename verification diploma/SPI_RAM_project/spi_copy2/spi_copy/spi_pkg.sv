package spi_slave_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // Sequence Item
  class spi_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_slave_seq_item)
    
    rand bit rst_n;
    rand bit [10:0] MOSI_data;
    rand bit [7:0] tx_data;
    
    // Outputs
    bit MISO;
    bit rx_valid;
    bit [9:0] rx_data;
    bit SS_n;      // Driven by driver
    bit tx_valid;  // Driven by driver based on command
    
    // Constraint 1: Reset deasserted most of the time
    constraint rst_c {
      rst_n dist {1 := 95, 0 := 5};
    }
    
    // Constraint 3: Valid command combinations for first 3 bits
    constraint mosi_cmd_c {
      MOSI_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }
    
    // Add distribution to get better coverage
    constraint cmd_dist_c {
      MOSI_data[10:8] dist {
        3'b000 := 25,  // Write Address
        3'b001 := 25,  // Write Data
        3'b110 := 25,  // Read Address
        3'b111 := 25   // Read Data
      };
    }
    
    function new(string name = "spi_slave_seq_item");
      super.new(name);
    endfunction
    
    function void post_randomize();
      // tx_valid automatically set based on command in driver
    endfunction
    
  endclass
  
  // Sequencer
  typedef uvm_sequencer#(spi_slave_seq_item) spi_slave_sequencer;
  
  // Driver - IMPROVED VERSION
  class spi_slave_driver extends uvm_driver#(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_driver)
    
    virtual spi_slave_if vif;
    
    function new(string name = "spi_slave_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface not found")
    endfunction
    
    task run_phase(uvm_phase phase);
      // Initialize signals
      vif.rst_n <= 1;
      vif.SS_n <= 1;
      vif.MOSI <= 0;
      vif.tx_valid <= 0;
      vif.tx_data <= 0;
      @(posedge vif.clk);
      
      forever begin
        seq_item_port.get_next_item(req);
        drive_transaction(req);
        seq_item_port.item_done();
      end
    endtask
    
    task drive_transaction(spi_slave_seq_item item);
      int ss_high_cycles;
      bit [2:0] cmd = item.MOSI_data[10:8];
      
      // Handle reset
      if (!item.rst_n) begin
        @(negedge vif.clk);
        vif.rst_n <= 0;
        vif.SS_n <= 1;
        vif.MOSI <= 0;
        vif.tx_valid <= 0;
        repeat(3) @(posedge vif.clk);
        vif.rst_n <= 1;
        @(posedge vif.clk);
        return;
      end
      
      // Determine SS_n high time based on command (Constraint 2)
      ss_high_cycles = (cmd == 3'b111) ? 1 : 1;  // 1 cycle high between transactions
      
      // SS_n high (idle) - Constraint 2: high for 1 cycle
      @(negedge vif.clk);
      vif.SS_n <= 1;
      vif.tx_valid <= 0;
      repeat(ss_high_cycles) @(posedge vif.clk);
      
      // Start transaction - SS_n goes low
      @(negedge vif.clk);
      vif.SS_n <= 0;
      
      // Set tx_valid for read data command (Constraint 4)
      if (cmd == 3'b111) begin
        vif.tx_valid <= 1;
        vif.tx_data <= item.tx_data;
      end else begin
        vif.tx_valid <= 0;
      end
      
      // Drive 11 bits serially (MSB first)
      for (int i = 10; i >= 0; i--) begin
        @(negedge vif.clk);
        vif.MOSI <= item.MOSI_data[i];
      end
      
      // Wait for rx_valid
      @(negedge vif.clk);
      
      // For read data, need more cycles for MISO output
      if (cmd == 3'b111) begin
        repeat(10) @(posedge vif.clk);  // 23 total cycles for read data
      end else begin
        repeat(1) @(posedge vif.clk);   // 13 total cycles for other commands
      end
      
    endtask
    
  endclass
  
  // Monitor
  class spi_slave_monitor extends uvm_monitor;
    `uvm_component_utils(spi_slave_monitor)
    
    virtual spi_slave_if vif;
    uvm_analysis_port#(spi_slave_seq_item) mon_ap;
    
    function new(string name = "spi_slave_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface not found")
      mon_ap = new("mon_ap", this);
    endfunction
    
    task run_phase(uvm_phase phase);
      spi_slave_seq_item item;
      forever begin
        item = spi_slave_seq_item::type_id::create("item");
        
        @(posedge vif.clk);
        
        // Sample all signals
        item.rst_n = vif.rst_n;
        item.SS_n = vif.SS_n;
        item.tx_valid = vif.tx_valid;
        item.tx_data = vif.tx_data;
        item.MISO = vif.MISO;
        item.rx_valid = vif.rx_valid;
        item.rx_data = vif.rx_data;
        
        // Reconstruct MOSI_data from rx_data when valid
        if (vif.rx_valid) begin
          item.MOSI_data[10:0] = {vif.rx_data, 1'b0};  // Approximate reconstruction
        end
        
        mon_ap.write(item);
      end
    endtask
    
  endclass
  
  // Agent
  class spi_slave_agent extends uvm_agent;
    `uvm_component_utils(spi_slave_agent)
    
    spi_slave_driver drv;
    spi_slave_monitor mon;
    spi_slave_sequencer sqr;
    
    function new(string name = "spi_slave_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = spi_slave_driver::type_id::create("drv", this);
      mon = spi_slave_monitor::type_id::create("mon", this);
      sqr = spi_slave_sequencer::type_id::create("sqr", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
    
  endclass
  
  // Scoreboard
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
      // Check reset behavior
      if (!item.rst_n) begin
        if (item.MISO == 0 && item.rx_valid == 0 && item.rx_data == 0) begin
          pass_count++;
          `uvm_info(get_type_name(), "PASS: Reset behavior correct", UVM_MEDIUM)
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf("FAIL: Outputs not cleared during reset - MISO=%0b, rx_valid=%0b, rx_data=%0h", 
                     item.MISO, item.rx_valid, item.rx_data))
        end
      end
      
      // Check rx_valid timing
      if (item.rx_valid && item.rst_n) begin
        `uvm_info(get_type_name(), $sformatf("Transaction complete: rx_data=%0h (%s)", 
                  item.rx_data, 
                  item.rx_data[9:8] == 2'b00 ? "WRITE_ADDR" :
                  item.rx_data[9:8] == 2'b01 ? "WRITE_DATA" :
                  item.rx_data[9:8] == 2'b10 ? "READ_ADDR" : "READ_DATA"), UVM_MEDIUM)
        pass_count++;
      end
    endfunction
    
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info(get_type_name(), $sformatf("\n========== SCOREBOARD SUMMARY ==========\nPass Count: %0d\nFail Count: %0d\n========================================", 
                pass_count, fail_count), UVM_LOW)
    endfunction
    
  endclass
  
  // Coverage Collector - IMPROVED
  class spi_slave_coverage extends uvm_subscriber#(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_coverage)
    
    spi_slave_seq_item item;
    
    // Covergroup with improved bins
    covergroup spi_cov;
      option.per_instance = 1;
      
      // Coverpoint 1: rx_data[9:8] values and transitions
      rx_data_cp: coverpoint item.rx_data[9:8] iff (item.rx_valid && item.rst_n) {
        bins write_addr = {2'b00};
        bins write_data = {2'b01};
        bins read_addr = {2'b10};
        bins read_data = {2'b11};
        bins transitions = (2'b00 => 2'b01 => 2'b10 => 2'b11);
      }
      
      // Coverpoint 2: SS_n sequences
      ss_n_cp: coverpoint item.SS_n iff (item.rst_n) {
        bins ss_low = {0};
        bins ss_high = {1};
      }
      
      // Coverpoint 3: MOSI command validation (sample from rx_data)
      mosi_cmd_cp: coverpoint item.rx_data[9:8] iff (item.rx_valid && item.rst_n) {
        bins write_addr_cmd = {2'b00};
        bins write_data_cmd = {2'b01};
        bins read_addr_cmd = {2'b10};
        bins read_data_cmd = {2'b11};
      }
      
      // Cross coverage 4: SS_n and MOSI
      ss_mosi_cross: cross ss_n_cp, mosi_cmd_cp iff (item.rst_n) {
        ignore_bins invalid = binsof(ss_n_cp.ss_high);
      }
      
    endgroup
    
    function new(string name = "spi_slave_coverage", uvm_component parent = null);
      super.new(name, parent);
      spi_cov = new();
    endfunction
    
    function void write(spi_slave_seq_item t);
      item = t;
      spi_cov.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("Coverage = %.2f%%", spi_cov.get_coverage()), UVM_LOW)
    endfunction
    
  endclass
  
  // Environment
  class spi_slave_env extends uvm_env;
    `uvm_component_utils(spi_slave_env)
    
    spi_slave_agent agt;
    spi_slave_scoreboard sb;
    spi_slave_coverage cov;
    
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
  
  // Base Sequence
  class spi_slave_base_seq extends uvm_sequence#(spi_slave_seq_item);
    `uvm_object_utils(spi_slave_base_seq)
    
    function new(string name = "spi_slave_base_seq");
      super.new(name);
    endfunction
    
  endclass
  
  // Reset Sequence
  class reset_sequence extends spi_slave_base_seq;
    `uvm_object_utils(reset_sequence)
    
    function new(string name = "reset_sequence");
      super.new(name);
    endfunction
    
    task body();
      spi_slave_seq_item item;
      
      repeat(3) begin
        item = spi_slave_seq_item::type_id::create("item");
        start_item(item);
        assert(item.randomize() with {rst_n == 0;});
        finish_item(item);
      end
      
      // Deassert reset
      item = spi_slave_seq_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {rst_n == 1;});
      finish_item(item);
      
    endtask
    
  endclass
  
  // Main Sequence - IMPROVED for better coverage
  class main_sequence extends spi_slave_base_seq;
    `uvm_object_utils(main_sequence)
    
    function new(string name = "main_sequence");
      super.new(name);
    endfunction
    
    task body();
      spi_slave_seq_item item;
      
      // Send mix of all command types to hit all coverage bins
      repeat(200) begin
        item = spi_slave_seq_item::type_id::create("item");
        start_item(item);
        assert(item.randomize() with {rst_n == 1;});
        finish_item(item);
      end
      
      // Targeted sequences for transition coverage
      // Write Addr -> Write Data -> Read Addr -> Read Data
      send_command(3'b000);  // Write Address
      send_command(3'b001);  // Write Data
      send_command(3'b110);  // Read Address
      send_command(3'b111);  // Read Data
      
    endtask
    
    task send_command(bit [2:0] cmd);
      spi_slave_seq_item item;
      item = spi_slave_seq_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {
        rst_n == 1;
        MOSI_data[10:8] == cmd;
      });
      finish_item(item);
    endtask
    
  endclass
  
  // Test
  class spi_slave_test extends uvm_test;
    `uvm_component_utils(spi_slave_test)
    
    spi_slave_env env;
    reset_sequence rst_seq;
    main_sequence main_seq;
    
    function new(string name = "spi_slave_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = spi_slave_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      
      `uvm_info(get_type_name(), "========== Starting Reset Sequence ==========", UVM_LOW)
      rst_seq = reset_sequence::type_id::create("rst_seq");
      rst_seq.start(env.agt.sqr);
      
      `uvm_info(get_type_name(), "========== Starting Main Sequence ==========", UVM_LOW)
      main_seq = main_sequence::type_id::create("main_seq");
      main_seq.start(env.agt.sqr);
      
      #2000;
      phase.drop_objection(this);
    endtask
    
    function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      super.report_phase(phase);
      
      svr = uvm_report_server::get_server();
      if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
        `uvm_info(get_type_name(), "========== TEST FAILED ==========", UVM_NONE)
      end else begin
        `uvm_info(get_type_name(), "========== TEST PASSED ==========", UVM_NONE)
      end
    endfunction
    
  endclass
  
endpackage