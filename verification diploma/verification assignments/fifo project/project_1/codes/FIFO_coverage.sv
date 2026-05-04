package FIFO_coverage;
    import FIFO_transaction::*;
    import shared_pkg::*;

    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;
        
        covergroup FIFO_cg;
            cp_write_en: coverpoint F_cvg_txn.wr_en {
                bins wr_en_zero = {1'b0};
                bins wr_active = {1'b1};
            }
            cp_read_en: coverpoint F_cvg_txn.rd_en {
                bins rd_en_zero = {1'b0};
                bins rd_active = {1'b1};
            }
            cp_full: coverpoint F_cvg_txn.full {
                bins full_asserted = {1'b1};
                bins full_deasserted = {1'b0};
            }
            cp_empty: coverpoint F_cvg_txn.empty {
                bins empty_asserted = {1'b1};
                bins empty_deasserted = {1'b0};
            }
            cp_almost_full: coverpoint F_cvg_txn.almostfull {
                bins almostfull_asserted = {1'b1};
                bins almostfull_deasserted = {1'b0};
            }
            cp_almost_empty: coverpoint F_cvg_txn.almostempty {
                bins almostempty_asserted = {1'b1};
                bins almostempty_deasserted = {1'b0};
            }
            cp_overflow: coverpoint F_cvg_txn.overflow {
                bins overflow_asserted = {1'b1};
                bins overflow_deasserted = {1'b0};
            }
            cp_underflow: coverpoint F_cvg_txn.underflow {
                option.weight = 0;
                bins underflow_asserted = {1'b1};
                bins underflow_deasserted = {1'b0};
            }
            cp_wr_ack: coverpoint F_cvg_txn.wr_ack {
                option.weight = 0;
                bins ack_asserted = {1'b1};
                bins ack_deasserted = {1'b0};
            }

            // 7 Cross coverages as required
            full_cv: cross cp_write_en, cp_read_en, cp_full {
                ignore_bins redundant_full = binsof(cp_read_en.rd_active) && binsof(cp_full.full_asserted);
            }
            empty_cv: cross cp_write_en, cp_read_en, cp_empty;
            almostempty_cv: cross cp_write_en, cp_read_en, cp_almost_empty;
            almostfull_cv: cross cp_write_en, cp_read_en, cp_almost_full;
            overflow_cv: cross cp_write_en, cp_read_en, cp_overflow {
                ignore_bins impossible_overflow = binsof(cp_write_en.wr_en_zero) && binsof(cp_overflow.overflow_asserted);
            }
            underflow_cv: cross cp_write_en, cp_read_en, cp_underflow {
                ignore_bins impossible_underflow = binsof(cp_read_en.rd_en_zero) && binsof(cp_underflow.underflow_asserted);
            }
            wr_ack_cv: cross cp_write_en, cp_read_en, cp_wr_ack {
                ignore_bins impossible_wr_ack = binsof(cp_write_en.wr_en_zero) && binsof(cp_wr_ack.ack_asserted);
            }
        endgroup

        function new();
            FIFO_cg = new;
        endfunction

        function void sample_data(input FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            FIFO_cg.sample();
        endfunction
    endclass
endpackage