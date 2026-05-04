module SPI_wrapper_assertions(
    input clk,
    input rst_n,
    input MOSI_data,
    input SS_n,
    input MISO,
    input rx_valid,
    input [9:0] rx_data,
    input [2:0] current_state
);

    parameter IDLE = 3'b000;
    parameter CHK_CMD = 3'b001;
    parameter WRITE = 3'b010;
    parameter READ_ADD = 3'b011;
    parameter READ_DATA = 3'b100;

    // Requirement 1: Reset behavior - outputs must be cleared
    property reset_outputs_p;
        @(posedge clk) (!rst_n) |-> (MISO == 0 && rx_valid == 0 && rx_data == 0);
    endproperty
    
    assert_reset_outputs: assert property (reset_outputs_p)
        else $error("WRAPPER ASSERTION FAILED: Outputs not cleared during reset - MISO=%b, rx_valid=%b, rx_data=%h", 
                    MISO, rx_valid, rx_data);

    // Requirement 2: MISO stability during non-read operations
    property miso_stable_p;
        @(posedge clk) disable iff (!rst_n)
        (current_state != READ_DATA && !SS_n) |=> $stable(MISO);
    endproperty
    
    assert_miso_stable: assert property (miso_stable_p)
        else $warning("WRAPPER ASSERTION: MISO changed during non-READ_DATA state");


endmodule