////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: Vending machine example
// 
////////////////////////////////////////////////////////////////////////////////
module vending_machine(vending_machine_if v_if);
// 1. Add the modport above

	reg [1:0] cs, ns;

	//Next State Logic
	always @(cs, v_if.Q_in, v_if.D_in) begin
		case (cs)
			v_if.WAIT: 
				if (v_if.Q_in)
					ns = v_if.Q_25;
				else 
					ns = v_if.WAIT;

			v_if.Q_25:
				if (v_if.Q_in)
					ns = v_if.Q_50;
				else 
					ns = v_if.Q_25;

			v_if.Q_50:
				if (v_if.Q_in)
					ns = v_if.WAIT;
				else 
					ns = v_if.Q_50;

			default: 	ns = v_if.WAIT;
		endcase
	end

	//State Memory
	always @(posedge v_if.clk or negedge v_if.rstn) begin
		if(~v_if.rstn)
			cs <= v_if.WAIT;
		else
			cs <= ns;
	end

	//Output Logic
	always @(cs, v_if.Q_in, v_if.D_in) begin 
		if ( (cs == v_if.WAIT && v_if.D_in == 1'b1) || (cs == v_if.Q_50 && v_if.Q_in == 1'b1) )	
			v_if.dispense = 1'b1;
		else 
			v_if.dispense = 1'b0;

		if (cs == v_if.WAIT && v_if.D_in == 1'b1) 
			v_if.change = 1'b1;
		else	
			v_if.change = 1'b0;
	end

endmodule