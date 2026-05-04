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
                almostempty_ref = 1; 
                wr_ack_ref = 0;
                overflow_ref = 0;
                underflow_ref = 0;
            end
            else begin
                // Reset flags at start of cycle
                wr_ack_ref = 0;
                overflow_ref = 0;
                underflow_ref = 0;
                data_out_ref = (mem_q.size() > 0) ? mem_q[0] : 0;
                
                // Handle simultaneous read and write
                if (trans_inputs.wr_en && trans_inputs.rd_en) begin
                    if (!full_ref) begin
                        // Write operation
                        mem_q.push_back(trans_inputs.data_in);
                        wr_ack_ref = 1;
                    end
                    if (!empty_ref) begin
                        // Read operation
                        data_out_ref = mem_q.pop_front();
                    end
                end
                else begin
                    // Separate read/write operations
                    if (trans_inputs.wr_en && !full_ref) begin
                        mem_q.push_back(trans_inputs.data_in);
                        wr_ack_ref = 1;
                    end
                    else if (trans_inputs.rd_en && !empty_ref) begin
                        data_out_ref = mem_q.pop_front();
                    end
                end
                
                // Handle overflow/underflow
                overflow_ref = (trans_inputs.wr_en && full_ref);
                underflow_ref = (trans_inputs.rd_en && empty_ref);
                
                // Calculate flags
                full_ref = (mem_q.size() == FIFO_DEPTH);
                empty_ref = (mem_q.size() == 0);
                almostfull_ref = (mem_q.size() == FIFO_DEPTH - 1);
                almostempty_ref = (mem_q.size() == 1);
            end
        endfunction

        function void check_data(input FIFO_transaction trans_inputs);
            ref_model(trans_inputs);
            
            // Check all outputs, not just data_out
            if (trans_inputs.data_out !== data_out_ref) begin
                $display("ERROR: data_out mismatch! Got=%h, Expected=%h, time=%0t", 
                        trans_inputs.data_out, data_out_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.full !== full_ref) begin
                $display("ERROR: full flag mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.full, full_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.empty !== empty_ref) begin
                $display("ERROR: empty flag mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.empty, empty_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.almostfull !== almostfull_ref) begin
                $display("ERROR: almostfull flag mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.almostfull, almostfull_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.almostempty !== almostempty_ref) begin
                $display("ERROR: almostempty flag mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.almostempty, almostempty_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.wr_ack !== wr_ack_ref) begin
                $display("ERROR: wr_ack mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.wr_ack, wr_ack_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.overflow !== overflow_ref) begin
                $display("ERROR: overflow mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.overflow, overflow_ref, $time);
                errors_count++;
            end
            else if (trans_inputs.underflow !== underflow_ref) begin
                $display("ERROR: underflow mismatch! Got=%b, Expected=%b, time=%0t", 
                        trans_inputs.underflow, underflow_ref, $time);
                errors_count++;
            end
            else begin
                correct_count++;
            end
        endfunction
    endclass
endpackage