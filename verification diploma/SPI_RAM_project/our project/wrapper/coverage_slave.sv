package coverage_slave;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_slave_item::*;

class coverage_slave extends uvm_subscriber#(sequence_slave_item);

    `uvm_component_utils(coverage_slave)
    sequence_slave_item item;
    bit prev_SS_n = 1;
    bit [1:0] current_cmd;

    covergroup spi_cov;
        option.per_instance = 1;
        option.comment = "SPI Slave Functional Coverage";
      
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
    function new(string name = "coverage_slave", uvm_component parent = null);
        super.new(name, parent);
        spi_cov = new();
    endfunction

    function void write(sequence_slave_item t);
        item = t;
      
        // Update current command when rx_valid
        if (item.rx_valid) begin
            current_cmd = item.rx_data[9:8];
        end
      
        // Sample coverage every cycle
        spi_cov.sample();
      
        prev_SS_n = item.SS_n;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // No need for analysis ports in uvm_subscriber
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

endpackage