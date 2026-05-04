////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: Vending machine example
// 
////////////////////////////////////////////////////////////////////////////////
module vending_machine_tb(vending_machine_if v_if);
// 1. Add the modport above

	//reset and initial values for inputs
  initial begin
    v_if.rstn = 0;
    v_if.Q_in = 0;
    v_if.D_in = 0;
    #50
    v_if.rstn = 1;
    #100;
        //Test dollars
         v_if.D_in = 1; v_if.Q_in = 0; 
        //Test Quarters 
    #100 v_if.D_in = 0; v_if.Q_in = 1; 
    #100 v_if.D_in = 0; v_if.Q_in = 0;
    #10;
    $stop;
  end

endmodule
