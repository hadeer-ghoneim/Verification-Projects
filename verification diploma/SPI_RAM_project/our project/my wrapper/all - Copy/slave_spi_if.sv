interface spi_slave_if (input bit clk);
  logic rst_n;
  logic MOSI;
  logic SS_n;
  logic tx_valid;
  logic [7:0] tx_data;
  logic MISO;
  logic rx_valid;
  logic [9:0] rx_data;
  
endinterface


/*
interface spi_slave_if (input bit clk);
  logic rst_n;
  logic MOSI;
  logic SS_n;
  logic tx_valid;
  logic [7:0] tx_data;
  logic MISO;
  logic rx_valid;
  logic [9:0] rx_data;
  
  // Clocking block for driver
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output rst_n;
    output MOSI;
    output SS_n;
    output tx_valid;
    output tx_data;
    input MISO;
    input rx_valid;
    input rx_data;
  endclocking
  
  // Clocking block for monitor
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input rst_n;
    input MOSI;
    input SS_n;
    input tx_valid;
    input tx_data;
    input MISO;
    input rx_valid;
    input rx_data;
  endclocking
  
  modport DRIVER (clocking driver_cb, input clk);
  modport MONITOR (clocking monitor_cb, input clk);
  
endinterface
*/



