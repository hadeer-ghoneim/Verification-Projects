module SPI_wrapper_assertions(
    input clk,
    input rst_n,
    input MOSI,
    input SS_n,
    input MISO,
    input rx_valid,tx_valid,
    input [9:0] rx_data
);


// 1- An assertion ensures that whenever reset is asserted, the output (MISO) is inactive.

// 2- An assertion to make sure that the MISO remains with a stable value eventually as long
// as it is not a read data operation

    // Requirement 1: Reset behavior - outputs must be cleared
    property reset_outputs_p;
        @(posedge clk) (!rst_n) |-> (MISO == 0);
    endproperty
    
    assert_reset_outputs: assert property (reset_outputs_p)
        else $error("WRAPPER ASSERTION FAILED: Outputs not cleared during reset - MISO=%b", MISO);

    // Requirement 2: MISO stability during non-read operations
    property miso_stable_p;
        @(posedge clk) disable iff (!rst_n)
        (tx_valid == 1) |-> $stable(MISO);
    endproperty
    
    assert_miso_stable: assert property (miso_stable_p)
        else $warning("WRAPPER ASSERTION: MISO changed during non-READ_DATA state");


endmodule