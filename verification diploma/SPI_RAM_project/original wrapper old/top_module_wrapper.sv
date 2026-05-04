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

    interface_wrapper if_wrapper(clk);
    interface_slave if_slave(clk);
    interface_ram if_ram(clk);


   // Individual DUT Instantiations (RAM and SPI Slave)
    SinglePort_SRAM #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256),
        .ADDR_SIZE(8)
    ) DUT_ram (
        .clk(if_ram.clk),
        .rst_n(if_ram.rst_n),
        .rx_valid(if_ram.rx_valid),
        .din(if_ram.din),
        .dout(if_ram.dout),
        .tx_valid(if_ram.tx_valid)
    );
    
    SPI_Slave DUT_slave(
        .clk(if_slave.clk),
        .rst_n(if_slave.rst_n),
        .MOSI(if_slave.MOSI),
        .SS_n(if_slave.SS_n),
        .tx_valid(if_slave.tx_valid),
        .tx_data(if_slave.tx_data),
        .MISO(if_slave.MISO),
        .rx_valid(if_slave.rx_valid),
        .rx_data(if_slave.rx_data)
    );

    // Main Wrapper DUT
    SPI_Wrapper DUT_wrapper(
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n),
        .SS_n(if_wrapper.SS_n),
        .MOSI(if_wrapper.MOSI),
        .MISO(if_wrapper.MISO)
    );
    
 golden_ram #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256),
        .ADDR_SIZE(8)
    ) golden_ram (
        .clk(if_ram.clk),
        .rst_n(if_ram.rst_n),
        .rx_valid(if_ram.rx_valid),
        .din(if_ram.din),
        .dout(if_ram.dout_ref),
        .tx_valid(if_ram.tx_valid_ref)
    );


golden_wrapper golden_wrapper(if_wrapper.MOSI,if_wrapper.SS_n ,if_wrapper.clk, if_wrapper.rst_n,if_wrapper.MISO_ref);

assign if_slave.MOSI=DUT_wrapper.MOSI;
assign if_slave.SS_n=DUT_wrapper.SS_n;
assign if_slave.rst_n=DUT_wrapper.rst_n;
assign if_ram.din=if_slave.rx_data;
assign if_ram.rx_valid=if_slave.rx_valid;
assign if_slave.tx_data=if_ram.dout;
assign if_slave.tx_valid=if_ram.tx_valid;
assign if_ram.rst_n=DUT_wrapper.rst_n;    


// Bind Assertion Modules - FIXED: Pass individual signals

 
    bind SPI_Wrapper SPI_wrapper_assertions spi_wrapper_assertions_inst (
        .clk(if_wrapper.clk),
        .rst_n(if_wrapper.rst_n),
        .MOSI(if_wrapper.MOSI),
        .SS_n(if_wrapper.SS_n),
        .MISO(if_wrapper.MISO),
        .rx_valid(if_slave.rx_valid),
        .rx_data(if_slave.rx_data),
        .current_state(DUT_slave.current)
    );


initial begin

    uvm_config_db#(virtual interface_wrapper)::set(null, "uvm_test_top", "vif", if_wrapper);
    uvm_config_db#(virtual interface_slave)::set(null, "uvm_test_top", "vif_slave", if_slave);
    uvm_config_db#(virtual interface_ram)::set(null, "uvm_test_top", "vif_ram", if_ram);
        run_test("test_wrapper");
    
end    




endmodule