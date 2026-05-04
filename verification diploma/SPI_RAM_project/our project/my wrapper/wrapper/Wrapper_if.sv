interface SPI_Wrapper_if(input clk);
    logic rst_n;
    logic SS_n;
    logic MOSI;
    logic MISO;
    
    // Internal signals for monitoring
    logic rx_valid;
    logic [9:0] rx_data;
    logic tx_valid;
    logic [7:0] tx_data;
    
    // RAM signals for reference model
    logic [7:0] ram_dout_ref;
    logic ram_tx_valid_ref;
    
    // Clocking blocks
    clocking driver_cb @(posedge clk);
        output rst_n, SS_n, MOSI;
        input MISO, rx_valid, rx_data, tx_valid, tx_data;
    endclocking
    
    clocking monitor_cb @(posedge clk);
        input rst_n, SS_n, MOSI, MISO, rx_valid, rx_data, tx_valid, tx_data;
    endclocking
    
    modport DRIVER (clocking driver_cb, input clk);
    modport MONITOR (clocking monitor_cb, input clk);
endinterface