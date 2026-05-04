module spi_slave_top;
  
  import uvm_pkg::*;
  import spi_slave_pkg::*;
  
  bit clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  spi_slave_if spi_if(clk);
  
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
  
  bind SPI_Slave spi_slave_assertions spi_assert (
    .clk(clk),
    .rst_n(spi_if.rst_n),  // FIXED: use spi_if.rst_n
    .MOSI(spi_if.MOSI),    // FIXED: use spi_if.MOSI
    .SS_n(spi_if.SS_n),    // FIXED: use spi_if.SS_n
    .MISO(spi_if.MISO),    // FIXED: use spi_if.MISO
    .rx_valid(spi_if.rx_valid),
    .rx_data(spi_if.rx_data),
    .current_state(dut.current)  // FIXED: reference from dut
  );
  
  initial begin
    uvm_config_db#(virtual spi_slave_if)::set(null, "*", "spi_slave_vif", spi_if);
    $dumpfile("spi_slave.vcd");
    $dumpvars(0, spi_slave_top);
    run_test("spi_slave_test");
  end
  
  initial begin
    #100000;
    $display("ERROR: Simulation timeout!");
    $finish;
  end
  
endmodule