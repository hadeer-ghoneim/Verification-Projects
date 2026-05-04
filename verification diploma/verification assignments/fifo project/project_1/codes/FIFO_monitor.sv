import FIFO_coverage::*;
import FIFO_transaction::*;
import FIFO_scoreboard::*;
import shared_pkg::*;

module FIFO_monitor(Sync_FIFO_interface.MON v_if);
    FIFO_coverage cov;
    FIFO_scoreboard sb;
    FIFO_transaction trans;

    initial begin
        trans = new();
        cov = new();
        sb = new();
        forever begin
            @(negedge v_if.clk);
            wait(v_if.etrigger.triggered);
            
            trans.data_in = v_if.data_in;
            trans.wr_ack = v_if.wr_ack;
            trans.rd_en = v_if.rd_en;
            trans.wr_en = v_if.wr_en;
            trans.overflow = v_if.overflow;
            trans.underflow = v_if.underflow;
            trans.full = v_if.full;
            trans.empty = v_if.empty;
            trans.almostempty = v_if.almostempty;
            trans.almostfull = v_if.almostfull;
            trans.data_out = v_if.data_out;
            trans.rst_n = v_if.rst_n;

            -> v_if.ttrigger;

            fork
                begin
                    cov.sample_data(trans);
                end
                begin
                    sb.check_data(trans);
                end
            join

            if (test_finished) begin
                $display("correct_count = %d, errors_count = %d", correct_count, errors_count);
                $stop;
            end
        end
    end
endmodule