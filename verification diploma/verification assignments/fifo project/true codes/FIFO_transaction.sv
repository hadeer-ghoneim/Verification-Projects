package FIFO_transaction;
    class FIFO_transaction #(parameter FIFO_WIDTH = 16, parameter FIFO_DEPTH = 8);
        rand bit [FIFO_WIDTH-1:0] data_in;
        rand bit rst_n, wr_en, rd_en;
        int RD_EN_ON_DIST, WR_EN_ON_DIST;
        logic [FIFO_WIDTH-1:0] data_out;
        bit wr_ack, overflow, underflow, full, empty, almostfull, almostempty;

        function new(input int RD_EN_ON_DIST = 30, input int WR_EN_ON_DIST = 70);
            this.RD_EN_ON_DIST = RD_EN_ON_DIST;
            this.WR_EN_ON_DIST = WR_EN_ON_DIST;
        endfunction

        constraint randoms{
            rst_n dist{ 1 :/ 98, 0 :/ 2 };
            wr_en dist{ 1 :/ WR_EN_ON_DIST, 0 :/ (100 - WR_EN_ON_DIST) };
            rd_en dist{ 1 :/ RD_EN_ON_DIST, 0 :/ (100 - RD_EN_ON_DIST) };
        }
    endclass
endpackage