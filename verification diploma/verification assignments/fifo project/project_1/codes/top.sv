module top();
    bit clk;
    
    initial begin
        clk = 0;
        forever #4 clk = ~clk;
    end

    Sync_FIFO_interface v_if(clk);
    FIFO DUT(v_if.DUT);
    FIFO_TB TB(v_if.TB);
    FIFO_monitor MON(v_if.MON);
    
    property reset_p;
        @(posedge v_if.clk) !v_if.rst_n |-> ((v_if.overflow == 0) && (v_if.underflow == 0));
    endproperty
    assert property(reset_p);
    cover property(reset_p);

endmodule