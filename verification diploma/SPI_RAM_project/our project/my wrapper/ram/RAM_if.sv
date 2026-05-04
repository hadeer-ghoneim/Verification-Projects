interface RAM_vif(input clk);
    // SPI_Wrapper connections
    logic rst_n;
    logic rx_valid;
    logic [9:0] din;
    logic [7:0] dout;
    logic tx_valid;
    
    // Reference model outputs
    logic [7:0] dout_ref;
    logic tx_valid_ref;
    
    // Internal monitoring signals for assertions
    logic [7:0] current_address;
    logic [7:0] mem_data;
    logic mem_write;
    
    // Clocking blocks for UVM
    clocking driver_cb @(posedge clk);
        output rst_n, rx_valid, din;
        input dout, tx_valid;
    endclocking
    
    clocking monitor_cb @(posedge clk);
        input rst_n, rx_valid, din, dout, tx_valid, dout_ref, tx_valid_ref;
    endclocking
    
    modport DRIVER (clocking driver_cb, input clk);
    modport MONITOR (clocking monitor_cb, input clk);

endinterface: RAM_vif