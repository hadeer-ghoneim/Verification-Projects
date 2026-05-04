package FIFO_scoreboard;
    import FIFO_transaction::*;
    import shared_pkg::*;

    class FIFO_scoreboard #(parameter FIFO_WIDTH = 16, parameter FIFO_DEPTH = 8);
        FIFO_transaction trans_inputs;
        logic [FIFO_WIDTH-1:0] data_out_ref;
        bit wr_ack_ref, overflow_ref, underflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref;
        logic [FIFO_WIDTH-1:0] mem_q[$];
        
        function void ref_model(input FIFO_transaction trans_inputs);
            if (!trans_inputs.rst_n) begin
                mem_q.delete();
                data_out_ref = 0;
                full_ref = 0;
                empty_ref = 1;
                almostfull_ref = 0;
                almostempty_ref = 0;
                wr_ack_ref = 0;
                overflow_ref = 0;
                underflow_ref = 0;
            end
            else begin
                if ((trans_inputs.wr_en && trans_inputs.rd_en) == 1) begin
                    if (mem_q.size() == 0) begin
                        // Only write when empty
                        mem_q.push_back(trans_inputs.data_in);
                        wr_ack_ref = 1;
                    end
                    else if (mem_q.size() == FIFO_DEPTH) begin
                        // Only read when full
                        data_out_ref = mem_q.pop_front();
                    end
                    else begin
                        // Both read and write
                        mem_q.push_back(trans_inputs.data_in);
                        data_out_ref = mem_q.pop_front();
                        wr_ack_ref = 1;
                    end
                end
                else begin
                    if (trans_inputs.wr_en && (mem_q.size() != FIFO_DEPTH)) begin
                        mem_q.push_back(trans_inputs.data_in);
                        wr_ack_ref = 1;
                    end
                    else if (trans_inputs.rd_en && (mem_q.size() != 0)) begin
                        data_out_ref = mem_q.pop_front();
                    end
                    else begin
                        wr_ack_ref = 0;
                    end
                end
                
                // Calculate flags
                full_ref = (mem_q.size() == FIFO_DEPTH);
                empty_ref = (mem_q.size() == 0);
                almostfull_ref = (mem_q.size() == FIFO_DEPTH - 1);
                almostempty_ref = (mem_q.size() == 1);
                overflow_ref = (trans_inputs.wr_en && full_ref);
                underflow_ref = (trans_inputs.rd_en && empty_ref);
            end
        endfunction

        function void check_data(input FIFO_transaction trans_inputs);
            ref_model(trans_inputs);
            if (trans_inputs.data_out != data_out_ref) begin
                $display("Test failed, error here Data_out = %h, Expected = %h, rd_en = %b, wr_en = %b",
                        trans_inputs.data_out, data_out_ref, trans_inputs.rd_en, trans_inputs.wr_en);
                errors_count++;
            end 
            else 
                correct_count++;
        endfunction
    endclass
endpackage