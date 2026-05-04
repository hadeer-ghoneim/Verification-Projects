module RAM_assertions(
    input clk,
    input rst_n,
    input rx_valid,
    input [9:0] din,
    input [7:0] dout,
    input tx_valid
);

    property reset_assert;
        @(posedge clk) disable iff(rst_n)
            (!rst_n) |=> (dout==0) && (tx_valid == 0);
    endproperty
    assert property(reset_assert);
    cover property (reset_assert);

    property input_assert;
        @(posedge clk) disable iff(!rst_n)
            (din[9:8] inside {2'b00, 2'b01, 2'b10})  |=> (tx_valid == 0);
    endproperty
    assert property(input_assert);
    cover property (input_assert);

    property output_assert;
        @(posedge clk) disable iff(!rst_n)
            (din[9:8] inside {2'b11} && rx_valid)  |=> (tx_valid == 1);
    endproperty
    assert property(output_assert);
    cover property (output_assert);

    property write_sequence_check;
        @(posedge clk) disable iff (!rst_n)
            (din[9:8] == 2'b00) |-> ##[1:$] (din[9:8] == 2'b01);
    endproperty
    assert property (write_sequence_check);
    cover property (write_sequence_check);

    property read_sequence_check;
        @(posedge clk) disable iff (!rst_n)
            (din[9:8] == 2'b10) |-> ##[1:$] (din[9:8] == 2'b11);
    endproperty
    assert property (read_sequence_check);
    cover property (read_sequence_check);

endmodule



/*
module RAM_assertions(
    RAM_vif r_if
);

    property reset_assert;
        @(posedge r_if.clk) disable iff(r_if.rst_n)
            (!r_if.rst_n) |=> (r_if.dout==0) && (r_if.tx_valid == 0);
    endproperty
    assert property(reset_assert);
    cover property (reset_assert);

    property input_assert;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.din[9:8] inside {2'b00, 2'b01, 2'b10})  |=> (r_if.tx_valid == 0);
    endproperty
    assert property(input_assert);
    cover property (input_assert);

    property output_assert;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.din[9:8] inside {2'b11} && r_if.rx_valid)  |=> (r_if.tx_valid == 1);
    endproperty
    assert property(output_assert);
    cover property (output_assert);

    property write_sequence_check;
        @(posedge r_if.clk) disable iff (!r_if.rst_n)
            (r_if.din[9:8] == 2'b00) |-> ##[1:$] (r_if.din[9:8] == 2'b01);
    endproperty
    assert property (write_sequence_check);
    cover property (write_sequence_check);

    property read_sequence_check;
        @(posedge r_if.clk) disable iff (!r_if.rst_n)
            (r_if.din[9:8] == 2'b10) |-> ##[1:$] (r_if.din[9:8] == 2'b11);
    endproperty
    assert property (read_sequence_check);
    cover property (read_sequence_check);


endmodule
*/