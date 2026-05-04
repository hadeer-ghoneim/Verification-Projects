module FIFO(Sync_FIFO_interface.DUT v_if);
    localparam max_fifo_addr = $clog2(v_if.FIFO_DEPTH);
    logic [v_if.FIFO_WIDTH-1:0] mem [v_if.FIFO_DEPTH-1:0];
    logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
    logic [max_fifo_addr:0] count;

    // Write logic - Fixed bugs
    always @(posedge v_if.clk or negedge v_if.rst_n) begin
        if (!v_if.rst_n) begin
            wr_ptr <= 0;
            v_if.wr_ack <= 0; // Fixed: wr_ack reset
            v_if.overflow <= 0; // Fixed: overflow reset
        end
        else if (v_if.wr_en && !v_if.full) begin
            mem[wr_ptr] <= v_if.data_in;
            v_if.wr_ack <= 1;
            wr_ptr <= wr_ptr + 1;
        end
        else begin
            v_if.wr_ack <= 0;
            if (v_if.full && v_if.wr_en)
                v_if.overflow <= 1;
            else
                v_if.overflow <= 0;
        end
    end

    // Read logic - Fixed bugs
    always @(posedge v_if.clk or negedge v_if.rst_n) begin
        if (!v_if.rst_n) begin
            rd_ptr <= 0;
            v_if.underflow <= 0; // Fixed: underflow is now sequential
        end
        else if (v_if.rd_en && !v_if.empty) begin
            v_if.data_out <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
        else begin // Fixed: underflow handling
            if (v_if.empty && v_if.rd_en)
                v_if.underflow <= 1;
            else
                v_if.underflow <= 0;
        end
    end

    // Count logic - Fixed simultaneous R/W handling
    always @(posedge v_if.clk or negedge v_if.rst_n) begin
        if (!v_if.rst_n) begin
            count <= 0;
        end
        else begin
            if (({v_if.wr_en, v_if.rd_en} == 2'b10) && !v_if.full)
                count <= count + 1;
            else if (({v_if.wr_en, v_if.rd_en} == 2'b01) && !v_if.empty)
                count <= count - 1;
            else if(({v_if.wr_en, v_if.rd_en} == 2'b11) && v_if.full) // Fixed: simultaneous R/W
                count <= count - 1;
            else if(({v_if.wr_en, v_if.rd_en} == 2'b11) && v_if.empty) // Fixed: simultaneous R/W
                count <= count + 1;
        end
    end

    // Combinational outputs - Fixed almostfull bug
    assign v_if.full = (count == v_if.FIFO_DEPTH);
    assign v_if.empty = (count == 0);
    assign v_if.almostfull = (count == v_if.FIFO_DEPTH - 1); // Fixed: DEPTH-1 not DEPTH-2
    assign v_if.almostempty = (count == 1);

`ifdef SIM
    // Assertions with conditional compilation
    property reset_internal;
        @(posedge v_if.clk) !v_if.rst_n |=> ((count == 0) && (rd_ptr == 0) && (wr_ptr == 0));
    endproperty
    assert property (reset_internal);
    cover property (reset_internal);

    property write_acknowledge_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (v_if.wr_en && !v_if.full) |=> v_if.wr_ack;
    endproperty
    assert property (write_acknowledge_p);
    cover property (write_acknowledge_p);

    property overflow_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (v_if.wr_en && v_if.full) |=> v_if.overflow;
    endproperty
    assert property (overflow_p);
    cover property (overflow_p);

    property underflow_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (v_if.rd_en && v_if.empty) |=> v_if.underflow;
    endproperty
    assert property (underflow_p);
    cover property (underflow_p);

    property empty_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (count == 0) |-> v_if.empty;
    endproperty
    assert property (empty_p);
    cover property (empty_p);

    property full_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (count == v_if.FIFO_DEPTH) |-> v_if.full;
    endproperty
    assert property (full_p);
    cover property (full_p);

    property almostfull_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (count == v_if.FIFO_DEPTH - 1) |-> v_if.almostfull;
    endproperty
    assert property (almostfull_p);
    cover property (almostfull_p);

    property almostempty_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (count == 1) |-> v_if.almostempty;
    endproperty
    assert property (almostempty_p);
    cover property (almostempty_p);

    property read_ptr_wrap_around_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (rd_ptr == v_if.FIFO_DEPTH - 1) && !v_if.empty && v_if.rd_en |=> (rd_ptr == 0);
    endproperty
    assert property (read_ptr_wrap_around_p);
    cover property (read_ptr_wrap_around_p);

    property write_ptr_wrap_around_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (wr_ptr == v_if.FIFO_DEPTH - 1) && !v_if.full && v_if.wr_en |=> (wr_ptr == 0);
    endproperty
    assert property (write_ptr_wrap_around_p);
    cover property (write_ptr_wrap_around_p);

    property wr_ptr_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (wr_ptr < v_if.FIFO_DEPTH);
    endproperty
    assert property (wr_ptr_p);
    cover property (wr_ptr_p);

    property rd_ptr_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (rd_ptr < v_if.FIFO_DEPTH);
    endproperty
    assert property (rd_ptr_p);
    cover property (rd_ptr_p);

    property count_p;
        @(posedge v_if.clk) disable iff(!v_if.rst_n)
        (count <= v_if.FIFO_DEPTH);
    endproperty
    assert property (count_p);
    cover property (count_p);
`endif
endmodule