interface interface_wrapper(input bit clk);
    // Basic SPI signals
    logic rst_n;
    logic MOSI_data;
    logic SS_n;
    logic MISO;
    logic MISO_ref; // For golden model
    
    // Internal signals for monitoring and assertions
    logic rx_valid;
    logic [9:0] rx_data;
    logic tx_valid;
    logic [7:0] tx_data;
    
    // Reference model outputs
    logic rx_valid_ref;
    logic [9:0] rx_data_ref;
    
    // FSM state for assertions
    logic [2:0] current_state;
    
    // Clocking blocks
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output rst_n, MOSI_data, SS_n;
        input MISO;
    endclocking
    
    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input rst_n, MOSI_data, SS_n, MISO, MISO_ref;
        input rx_valid, rx_data, tx_valid, tx_data;
        input rx_valid_ref, rx_data_ref;
        input current_state;
    endclocking
    
    modport DRIVER (clocking driver_cb, input clk);
    modport MONITOR (clocking monitor_cb, input clk);
endinterface
