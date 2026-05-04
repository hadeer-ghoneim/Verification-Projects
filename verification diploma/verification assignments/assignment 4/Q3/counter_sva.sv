module counter_sva(counter_if.SVA vif);
    
    // i. When load is active, dout equals din
    property p_load;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        !vif.load_n |-> (vif.count_out == vif.data_load);
    endproperty
    a_load: assert property (p_load);
    c_load: cover property (p_load);
    
   // ii. When load inactive and enable off, dout doesn't change
    property p_no_change;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.load_n && !vif.ce && vif.rst_n) |-> (vif.count_out == $past(vif.count_out));
    endproperty

    // iii. When load inactive, enable active, and up_down high, dout increments
    property p_increment;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.load_n && vif.ce && vif.up_down) |-> 
        (vif.count_out == $past(vif.count_out) + 1'b1);
    endproperty
    a_increment: assert property (p_increment);
    c_increment: cover property (p_increment);
    
    // iv. When load inactive, enable active, and up_down low, dout decrements
    property p_decrement;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.load_n && vif.ce && !vif.up_down) |-> 
        (vif.count_out == $past(vif.count_out) - 1'b1);
    endproperty
    a_decrement: assert property (p_decrement);
    c_decrement: cover property (p_decrement);
    
    // v. Async reset check using assert final
    always_comb begin
        if(!vif.rst_n) begin
            a_reset: assert final(vif.count_out == 0);
        end
    end
    
    // vi. max_count output is high when counter output is maximum
    property p_max_count;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.count_out == 4'b1111) |-> vif.max_count;
    endproperty
    a_max_count: assert property (p_max_count);
    c_max_count: cover property (p_max_count);
    
    // vii. zero output is high when counter output is zero
    property p_zero;
        @(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.count_out == 0) |-> vif.zero;
    endproperty
    a_zero: assert property (p_zero);
    c_zero: cover property (p_zero);

endmodule

/*
counter_sva.sv
module counter_sva #(parameter WIDTH = 4) (counter_if.SVA vif);

    //======================================================
    // Example Assertions
    //======================================================

    // 1) Increment check
    assert property (@(posedge vif.clk) disable iff (!vif.rst_n)
        (vif.ce && vif.up_down) |-> (vif.count_out == $past(vif.count_out) + 1'b1))
        else $error("Count did not increment as expected.");

    // 2) Load check
    assert property (@(posedge vif.clk) disable iff (!vif.rst_n)
        (!vif.load_n) |-> (vif.count_out == vif.data_load))
        else $error("Load operation failed: count_out != data_load.");

    // 3) Zero flag check
    assert property (@(posedge vif.clk)
        (vif.count_out == 0) |-> (vif.zero))
        else $error("Zero flag not set correctly.");

    // 4) Max flag check
    assert property (@(posedge vif.clk)
        (vif.count_out == {WIDTH{1'b1}}) |-> (vif.max_count))
        else $error("Max flag not set correctly.");

endmodule
*/


//Guide lines:
// 1. Add the modport above
// 2. Add the following 3 properties, then use assert property and cover property on each property
//// First Assertion: At each positive edge of the clock, if the D_in is high then at the same clock cycle, the dispense and the change outputs are high
//// Second Assertion: At each positive edge of the clock, If there is a rising edge for the input Q_in then after 2 clock cycles the dispense output is high
//// Third Assertion: At each positive edge of the clock, if the Q_in is high then at the same clock cycle, the change must be low

