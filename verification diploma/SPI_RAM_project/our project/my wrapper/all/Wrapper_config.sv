package config_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;

class config_wrapper extends uvm_object;
    `uvm_object_utils(config_wrapper)

    // Virtual interfaces for both SPI and RAM
    virtual spi_slave_if spi_vif;          // SPI interface
    virtual RAM_if if_ram;               // RAM interface
    
    // Agent configuration
    uvm_active_passive_enum spi_agent_mode = UVM_ACTIVE;  // SPI agent is active
    uvm_active_passive_enum ram_agent_mode = UVM_PASSIVE; // RAM agent is passive
    
    // Test configuration
    int num_transactions = 100;            // Number of test transactions
    bit enable_coverage = 1;               // Enable coverage collection
    bit enable_scoreboard = 1;             // Enable scoreboard checking
    
    // SPI Protocol configuration
    bit [2:0] valid_commands[] = '{3'b000, 3'b001, 3'b110, 3'b111}; // Valid SPI commands
    int spi_clock_period = 10;             // 10 time units per SPI clock cycle
    
    // Timeout configuration
    int simulation_timeout = 1000000;      // Simulation timeout in time units

    // Constructor
    function new(string name = "config_wrapper");
        super.new(name);
    endfunction

    // Function to display configuration - FIXED
    function void display_config();
        `uvm_info("CONFIG", $sformatf(
            "SPI Agent Mode: %s\nRAM Agent Mode: %s\nNum Transactions: %0d\nCoverage: %0b\nScoreboard: %0b\nSPI Clock Period: %0d\nSimulation Timeout: %0d",
            (spi_agent_mode == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE",
            (ram_agent_mode == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE",
            num_transactions,
            enable_coverage,
            enable_scoreboard,
            spi_clock_period,
            simulation_timeout
        ), UVM_LOW)
    endfunction

    // Function to set SPI agent mode
    function void set_spi_agent_mode(uvm_active_passive_enum mode);
        spi_agent_mode = mode;
        `uvm_info("CONFIG", $sformatf("SPI Agent mode set to: %s", 
                  (mode == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE"), UVM_MEDIUM)
    endfunction

    // Function to set RAM agent mode  
    function void set_ram_agent_mode(uvm_active_passive_enum mode);
        ram_agent_mode = mode;
        `uvm_info("CONFIG", $sformatf("RAM Agent mode set to: %s", 
                  (mode == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE"), UVM_MEDIUM)
    endfunction

endclass
    
endpackage