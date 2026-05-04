import FIFO_coverage::*;
import FIFO_transaction::*;
import FIFO_scoreboard::*;
import shared_pkg::*;

module FIFO_TB(Sync_FIFO_interface.TB v_if);
    FIFO_transaction trans;
    int stopped = 79999;
    
    initial begin
        trans = new();
        v_if.rst_n = 0;
        @(negedge v_if.clk);
        v_if.rst_n = 1;
        @(negedge v_if.clk);

        repeat (10000) begin
            v_if.rd_en = 0; 
            v_if.wr_en = 1; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            wait(v_if.ttrigger.triggered);
        end

        repeat (10000) begin
            v_if.rd_en = 1; 
            v_if.wr_en = 1; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            wait(v_if.ttrigger.triggered);
        end

        repeat (10000) begin
            v_if.rd_en = 1; 
            v_if.wr_en = 0; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            wait(v_if.ttrigger.triggered);
        end

        for (int i = 0; i <= stopped; ++i) begin
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            v_if.rd_en = trans.rd_en;
            v_if.wr_en = trans.wr_en;
            v_if.rst_n = trans.rst_n;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            if (i != stopped) 
                wait(v_if.ttrigger.triggered);
        end
        
        test_finished = 1;
    end
endmodule