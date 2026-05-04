module SPI_Wrapper_golden_model(
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO_ref
);

    wire [7:0] tx_data_ref;
    wire [9:0] rx_data_ref;
    wire tx_valid_ref;
    wire rx_valid_ref;

    // Reference SPI Slave
    SPI_Slave SPI_ref(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .tx_valid(tx_valid_ref),
        .tx_data(tx_data_ref),
        .MISO(MISO_ref),
        .rx_data(rx_data_ref),
        .rx_valid(rx_valid_ref)
    );

    // Reference RAM
    SinglePort_SRAM #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256),
        .ADDR_SIZE(8)
    ) RAM_ref (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid_ref),
        .din(rx_data_ref),
        .dout(tx_data_ref),
        .tx_valid(tx_valid_ref)
    );

endmodule