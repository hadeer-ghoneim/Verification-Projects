module spi_slave_top;
  
  import uvm_pkg::*;
  import spi_slave_pkg::*;
  
  // Clock generation
  bit clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Interface instantiation
  spi_slave_if spi_if(clk);
  
  // DUT instantiation
  SPI_Slave dut (
    .clk(spi_if.clk),
    .rst_n(spi_if.rst_n),
    .MOSI(spi_if.MOSI),
    .SS_n(spi_if.SS_n),
    .tx_valid(spi_if.tx_valid),
    .tx_data(spi_if.tx_data),
    .MISO(spi_if.MISO),
    .rx_valid(spi_if.rx_valid),
    .rx_data(spi_if.rx_data)
  );
  
  // Bind assertions module
  bind SPI_Slave spi_slave_assertions spi_assert (
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .SS_n(SS_n),
    .MISO(MISO),
    .rx_valid(rx_valid),
    .rx_data(rx_data),
    .current_state(current)
  );
  
  initial begin
    // Set interface in config_db
    uvm_config_db#(virtual spi_slave_if)::set(null, "*", "spi_slave_vif", spi_if);
    
    // Enable waveform dump
    $dumpfile("spi_slave.vcd");
    $dumpvars(0, spi_slave_top);
    
    // Run test
    run_test("spi_slave_test");
  end
  
  // Watchdog timer
  initial begin
    #100000;
    $display("ERROR: Timeout!");
    $finish;
  end
  
endmodule