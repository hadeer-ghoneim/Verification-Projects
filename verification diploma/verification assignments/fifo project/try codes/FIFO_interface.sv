interface Sync_FIFO_interface(input bit clk);
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    bit [FIFO_WIDTH-1:0] data_in, data_out;
    bit rst_n, wr_en, rd_en, wr_ack, overflow, underflow,
    full, empty, almostfull, almostempty;
    event etrigger, ttrigger;
    
    modport DUT (
        input data_in, clk, rst_n, wr_en, rd_en,
        output data_out, wr_ack, overflow, underflow, full, empty,
        almostfull, almostempty
    );

    modport TB (
        input clk, etrigger, ttrigger, data_out, wr_ack, overflow,
        underflow, full, empty, almostfull, almostempty,
        output data_in, rst_n, wr_en, rd_en
    );

    modport MON (
        input clk, data_out, wr_ack, overflow, underflow, full,
        empty, almostfull, almostempty, data_in, rst_n,
        wr_en, rd_en, etrigger, ttrigger
    );
endinterface