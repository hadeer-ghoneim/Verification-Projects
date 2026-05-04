module wrapper (
	
	MOSI,MISO,SS_n,clk,rst_n
	
);
	

	input MOSI,SS_n,clk,rst_n;
	output MISO ;

	wire [9:0]rx_data;
	wire rx_valid,tx_valid;
	wire [7:0]tx_data;

	slave S1(MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

	ram RAM(rx_data,rx_valid,clk,rst_n,tx_data,tx_valid);
endmodule : wrapper


// ===================== WRAPPER_ASSERTIONS.sv =====================
`ifdef SIM
module wrapper_assertions(
    input logic clk, rst_n, SS_n, MOSI, MISO
);

    // Assertion 1: Reset condition
    property reset_assertions;
        !rst_n |-> (MISO == 0);
    endproperty
    ASSERT_RESET: assert property (@(posedge clk) reset_assertions)
        else $error("Wrapper: MISO not low during reset");
    
    // Assertion 2: MISO stability during non-read operations
    property miso_stability;
        !SS_n && MOSI !== 1'bx |-> 
        ##1 $stable(MISO) throughout (##[0:10] SS_n);
    endproperty
    ASSERT_MISO_STABLE: assert property (@(posedge clk) miso_stability)
        else $error("Wrapper: MISO not stable during communication");

endmodule
`endif