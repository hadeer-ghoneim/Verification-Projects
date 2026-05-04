
module SPI_Wrapper(
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
);

    wire [7:0] tx_data;
    wire [9:0] rx_data;
    wire tx_valid;
    wire rx_valid;

    SPI_Slave SPI(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .MISO(MISO),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    SinglePort_SRAM #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256),
        .ADDR_SIZE(8)
    ) RAM (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .din(rx_data),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );

endmodule