//======================================================
// Vending Machine Monitor
//======================================================
module vending_machine_monitor(vending_machine_if.MONITOR v_if);

// Test monitor and results
initial begin
  $monitor("rstn = %b, clk = %b, Q_in = %b, D_in = %b, dispense = %b, change = %b", 
            v_if.rstn, v_if.clk, v_if.Q_in, v_if.D_in, v_if.dispense, v_if.change);
end

endmodule

//======================================================
// Vending Machine Assertions and Coverage (SVA)
//======================================================
module vending_machine_sva(vending_machine_if.DUT v_if);

  // Property for dollar insertion
  property p_dollar;
    @(posedge v_if.clk) v_if.D_in |-> (v_if.dispense && v_if.change);
  endproperty

  // Property for quarter dispense
  property p_quarter_dispense;
    @(posedge v_if.clk) $rose(v_if.Q_in) |-> ##2 v_if.dispense;
  endproperty

  // Property for quarter leading to change
  property p_quarter_v_if_change;
    @(posedge v_if.clk) (v_if.Q_in |-> (v_if.change));
  endproperty

  // Assertions
  Dollar_assertion:              assert property(p_dollar);
  Quarter_v_if_dispense_assertion: assert property(p_quarter_dispense);
  Quarter_v_if_change_assertion:   assert property(p_quarter_v_if_change);

  // Coverage
  Dollar_coverage:                cover property(p_dollar);
  Quarter_v_if_dispense_coverage: cover property(p_quarter_dispense);
  Quarter_v_if_change_coverage:   cover property(p_quarter_v_if_change);

endmodule

//======================================================
// Vending Machine Testbench Module
//======================================================
module vending_machine_tb(vending_machine_if.TEST v_if);
  // This module can be extended to generate test sequences
endmodule

//======================================================
// Top-Level Module
//======================================================
module vending_machine_top();
  bit clk;

  // Clock generation
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  // Interface instantiation
  vending_machine_if v_if(clk);

  // Module instantiations
  vending_machine_tb tb(v_if);
  vending_machine dut(v_if);
  vending_machine_monitor mon(v_if);

  // Binding SVA module to DUT
  bind vending_machine vending_machine_sva vending_machine_sva_inst(v_if);

endmodule

//======================================================
// Vending Machine DUT Module
//======================================================
module vending_machine(vending_machine_if.DUT v_if);
  // DUT implementation goes here
endmodule
