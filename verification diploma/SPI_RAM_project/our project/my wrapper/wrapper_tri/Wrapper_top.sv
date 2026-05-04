module Wrapper_top();
`include "uvm_macros.svh"
import uvm_pkg::*;
import test_wrapper::*;

    bit clk;
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    // Interfaces using existing ones
    spi_slave_if if_slave(clk);      // Using existing spi_slave_if
    RAM_if if_ram(clk);             // Using existing RAM_vif
    interface_wrapper if_wrapper(clk); // Wrapper interface

    // Main Wrapper DUT
    SPI_Wrapper DUT_wrapper(
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n),
        .SS_n(if_wrapper.SS_n),
        .MOSI_data(if_wrapper.MOSI_data),
        .MISO(if_wrapper.MISO)
    );
   
    // ============================================================
    // CONNECTIONS FOR ACTIVE WRAPPER + PASSIVE RAM/SLAVE
    // ============================================================
    assign if_slave.MOSI_data=DUT_wrapper.MOSI_data;
    assign if_slave.SS_n=DUT_wrapper.SS_n;
    assign if_slave.rst_n=DUT_wrapper.rst_n;
    assign if_ram.din=if_slave.rx_data;
    assign if_ram.rx_valid=if_slave.rx_valid;
    assign if_slave.tx_data=if_ram.dout;
    assign if_slave.tx_valid=if_ram.tx_valid;
    assign if_ram.rst_n=DUT_wrapper.rst_n;    
    

    bind SPI_Wrapper SPI_wrapper_assertions spi_wrapper_assertions_inst (
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n),
        .MOSI_data(if_wrapper.MOSI_data),
        .SS_n(if_wrapper.SS_n),
        .MISO(if_wrapper.MISO),
        .rx_valid(if_slave.rx_valid),
        .rx_data(if_slave.rx_data)
    );

    initial begin
        // Set virtual interfaces in UVM config database
        uvm_config_db#(virtual spi_slave_if)::set(null, "uvm_test_top", "spi_slave_vif", if_slave);
        uvm_config_db#(virtual RAM_if)::set(null, "uvm_test_top", "ram_vif", if_ram);
        uvm_config_db#(virtual interface_wrapper)::set(null, "uvm_test_top", "wrapper_vif", if_wrapper);
        
        // Run test
        run_test("SPI_Wrapper_test");
    end

endmodule