import FIFO_coverage::*;
import FIFO_transaction::*;
import FIFO_scoreboard::*;
import shared_pkg::*;

module FIFO_TB(Sync_FIFO_interface.TB v_if);
    FIFO_transaction trans;
    int stopped = 79999;
    
    initial begin
        trans = new();
        
        // Initial reset
        v_if.rst_n = 0;
        v_if.wr_en = 0;
        v_if.rd_en = 0;
        v_if.data_in = 0;
        repeat(2) @(negedge v_if.clk);
        v_if.rst_n = 1;
        @(negedge v_if.clk);

        // Write only phase
        repeat (10000) begin
            v_if.rd_en = 0; 
            v_if.wr_en = 1; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            @(v_if.ttrigger); // Wait for monitor to finish
        end

        // Simultaneous read/write phase
        repeat (10000) begin
            v_if.rd_en = 1; 
            v_if.wr_en = 1; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            @(v_if.ttrigger);
        end

        // Read only phase
        repeat (10000) begin
            v_if.rd_en = 1; 
            v_if.wr_en = 0; 
            v_if.rst_n = 1;
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            @(v_if.ttrigger);
        end

        // Random phase
        for (int i = 0; i <= stopped; ++i) begin
            assert(trans.randomize());
            v_if.data_in = trans.data_in;
            v_if.rd_en = trans.rd_en;
            v_if.wr_en = trans.wr_en;
            v_if.rst_n = trans.rst_n;
            @(negedge v_if.clk);
            ->v_if.etrigger;
            if (i != stopped) 
                @(v_if.ttrigger);
        end
        
        test_finished = 1;
        $display("Test finished at time %0t", $time);
    end
endmodule