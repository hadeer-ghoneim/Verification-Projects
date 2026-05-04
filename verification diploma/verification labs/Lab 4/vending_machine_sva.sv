////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: Vending machine example
// 
////////////////////////////////////////////////////////////////////////////////
module vending_machine_sva(vending_machine_if v_if);
// 1. Add the modport above
// 2. Add the following 3 properties, then use assert property and cover property on each property
//// First Assertion: At each positive edge of the clock, if the D_in is high then at the same clock cycle, the dispense and the change outputs are high
//// Second Assertion: At each positive edge of the clock, If there is a rising edge for the input Q_in then after 2 clock cycles the dispense output is high
//// Third Assertion: At each positive edge of the clock, if the Q_in is high then at the same clock cycle, the change must be low

endmodule