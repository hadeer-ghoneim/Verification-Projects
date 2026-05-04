module top_module_wrapper();
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

    // Interfaces
    interface_wrapper if_wrapper(clk);
    interface_slave if_slave(clk);
    interface_ram if_ram(clk);

    // DUT Instantiations
    ram DUT_ram(
        .din(if_ram.din),
        .rx_valid(if_ram.rx_valid), 
        .clk(if_ram.clk),
        .rst_n(if_ram.rst_n),
        .dout(if_ram.dout),
        .tx_valid(if_ram.tx_valid)
    );

    // golden_ram without reference outputs
    golden_ram golden_ram(
        .din(if_ram.din),
        .rx_valid(if_ram.rx_valid),
        .clk(if_ram.clk),
        .rst_n(if_ram.rst_n),
        .dout(if_ram.dout_ref),      // Connect directly to dout_ref
        .tx_valid(if_ram.tx_valid_ref) // Connect directly to tx_valid_ref
    );

    slave DUT_slave(
        .MOSI(if_slave.MOSI),
        .MISO(if_slave.MISO),
        .SS_n(if_slave.SS_n),
        .clk(if_slave.clk),
        .rst_n(if_slave.rst_n),
        .rx_data(if_slave.rx_data),
        .rx_valid(if_slave.rx_valid),
        .tx_data(if_slave.tx_data),
        .tx_valid(if_slave.tx_valid)
    );

    // Connect internal signals from slave for assertions
    wire [2:0] slave_current_state = DUT_slave.cs;  // FSM state
    wire [3:0] slave_counter = DUT_slave.counter;    // bit counter
    wire slave_confirm_add = DUT_slave.confirm_add;  // address confirmation

    // golden_slave without reference outputs
    golden_slave golden(
        .MOSI(if_slave.MOSI),
        .clk(if_slave.clk),
        .rst_n(if_slave.rst_n),
        .SS_n(if_slave.SS_n),
        .tx_valid(if_slave.tx_valid),
        .tx_data(if_slave.tx_data),
        .MISO(if_slave.MISO_ref),      // Connect MISO to MISO_ref
        .rx_valid(if_slave.rx_valid_ref), // Connect rx_valid to rx_valid_ref
        .rx_data(if_slave.rx_data_ref)   // Connect rx_data to rx_data_ref
    );

    wrapper DUT_wrapper(
        .MOSI(if_wrapper.MOSI),
        .MISO(if_wrapper.MISO),
        .SS_n(if_wrapper.SS_n),
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n)
    );

    // golden_wrapper without reference output
    golden_wrapper golden_wrapper(
        .MOSI(if_wrapper.MOSI),
        .SS_n(if_wrapper.SS_n),
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n),
        .MISO(if_wrapper.MISO_ref)  // Connect MISO to MISO_ref
    );

    // Signal assignments
    assign if_slave.MOSI = DUT_wrapper.MOSI;
    assign if_slave.SS_n = DUT_wrapper.SS_n;
    assign if_slave.rst_n = DUT_wrapper.rst_n;
    assign if_ram.din = if_slave.rx_data;
    assign if_ram.rx_valid = if_slave.rx_valid;
    assign if_slave.tx_data = if_ram.dout;
    assign if_slave.tx_valid = if_ram.tx_valid;
    assign if_ram.rst_n = DUT_wrapper.rst_n;

    // Instantiate assertion modules
    spi_slave_assertions slave_assertions_inst(
        .clk(if_slave.clk),
        .rst_n(if_slave.rst_n),
        .MOSI(if_slave.MOSI),
        .SS_n(if_slave.SS_n),
        .MISO(if_slave.MISO),
        .rx_valid(if_slave.rx_valid),
        .rx_data(if_slave.rx_data),
        .current_state(slave_current_state),
        .confirm_add(slave_confirm_add),
        .counter(slave_counter),
        .tx_data(if_slave.tx_data),
        .tx_valid(if_slave.tx_valid)
    );

    RAM_assertions ram_assertions_inst(
        .r_if(if_ram)
    );

    initial begin
        // Set virtual interfaces in UVM config DB
        uvm_config_db#(virtual interface_wrapper)::set(null, "uvm_test_top", "vif", if_wrapper);
        uvm_config_db#(virtual interface_slave)::set(null, "uvm_test_top", "vif_slave", if_slave);
        uvm_config_db#(virtual interface_ram)::set(null, "uvm_test_top", "vif_ram", if_ram);
        
        // ALSO set virtual interface directly for slave monitor as backup
        uvm_config_db#(virtual interface_slave)::set(null, "uvm_test_top.env_slaver.agt_slave.mon_slave", "vif_slave", if_slave);
        
        run_test("test_wrapper");
    end

    // Add some debug initial block to monitor signals
    initial begin
        #100;
        $display("=== TOP MODULE DEBUG ===");
        $display("Time: %0t", $time);
        $display("clk: %b", clk);
        $display("if_slave.rst_n: %b", if_slave.rst_n);
        $display("if_slave.SS_n: %b", if_slave.SS_n);
        $display("if_slave.MOSI: %b", if_slave.MOSI);
        $display("if_slave.MISO: %b", if_slave.MISO);
        $display("========================");
    end

endmodule