interface RAM_if(
    input clk
);
    logic [9:0] din;
    logic rst_n, rx_valid;
    logic [7:0] dout, dout_ref;
    logic tx_valid, tx_valid_ref;

endinterface: RAM_if