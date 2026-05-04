module RAM_assertions(
    interface_ram r_if
);

    property reset_assert;
        @(posedge r_if.clk) disable iff(r_if.rst_n)
            (!r_if.rst_n) |=> (r_if.dout == 0) && (r_if.tx_valid == 0);
    endproperty
    assert_reset: assert property(reset_assert)
        else $error("Reset assertion failed: outputs not cleared");
    cover_reset: cover property (reset_assert);

    // Write address sequence: after 2'b00 with rx_valid, next should be 2'b01
    property write_sequence_check;
        @(posedge r_if.clk) disable iff (!r_if.rst_n)
            (r_if.rx_valid && r_if.din[9:8] == 2'b00) |-> ##[1:100] 
            (r_if.rx_valid && r_if.din[9:8] == 2'b01);
    endproperty
    assert_write_sequence: assert property (write_sequence_check)
        else $error("Write sequence violation: 00 not followed by 01");
    cover_write_sequence: cover property (write_sequence_check);

    // Read address sequence: after 2'b10 with rx_valid, next should be 2'b11  
    property read_sequence_check;
        @(posedge r_if.clk) disable iff (!r_if.rst_n)
            (r_if.rx_valid && r_if.din[9:8] == 2'b10) |-> ##[1:100]
            (r_if.rx_valid && r_if.din[9:8] == 2'b11);
    endproperty
    assert_read_sequence: assert property (read_sequence_check)
        else $error("Read sequence violation: 10 not followed by 11");
    cover_read_sequence: cover property (read_sequence_check);

    // tx_valid should only assert for read data command (2'b11) with rx_valid
    property tx_valid_assertion;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.tx_valid) |-> (r_if.rx_valid && r_if.din[9:8] == 2'b11);
    endproperty
    assert_tx_valid: assert property(tx_valid_assertion)
        else $error("tx_valid asserted without read data command");
    cover_tx_valid: cover property (tx_valid_assertion);

    // tx_valid should be 0 for all commands except read data
    property tx_valid_low_for_non_read;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.rx_valid && r_if.din[9:8] inside {2'b00, 2'b01, 2'b10}) |=> (r_if.tx_valid == 0);
    endproperty
    assert_tx_valid_low: assert property(tx_valid_low_for_non_read)
        else $error("tx_valid should be 0 for non-read commands");
    cover_tx_valid_low: cover property (tx_valid_low_for_non_read);

    // tx_valid should be 1 for read data command
    property tx_valid_high_for_read_data;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.rx_valid && r_if.din[9:8] == 2'b11) |=> (r_if.tx_valid == 1);
    endproperty
    assert_tx_valid_high: assert property(tx_valid_high_for_read_data)
        else $error("tx_valid should be 1 for read data command");
    cover_tx_valid_high: cover property (tx_valid_high_for_read_data);

    // tx_valid should be 0 in the cycle after read data command
    property tx_valid_one_cycle;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.tx_valid) |=> (r_if.tx_valid == 0);
    endproperty
    assert_tx_valid_pulse: assert property(tx_valid_one_cycle)
        else $error("tx_valid should be a one-cycle pulse");
    cover_tx_valid_pulse: cover property (tx_valid_one_cycle);

    // dout should remain stable when not in read data mode
    property dout_stable;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (!r_if.tx_valid && $past(!r_if.tx_valid)) |-> $stable(r_if.dout);
    endproperty
    assert_dout_stable: assert property(dout_stable)
        else $warning("dout changed when not expected");
    cover_dout_stable: cover property (dout_stable);

    // rx_valid required for any command processing
    property rx_valid_required;
        @(posedge r_if.clk) disable iff(!r_if.rst_n)
            (r_if.din[9:8] inside {2'b00, 2'b01, 2'b10, 2'b11}) |-> r_if.rx_valid;
    endproperty
    assert_rx_valid_required: assert property(rx_valid_required)
        else $warning("Command received without rx_valid");
    cover_rx_valid_required: cover property (rx_valid_required);

endmodule