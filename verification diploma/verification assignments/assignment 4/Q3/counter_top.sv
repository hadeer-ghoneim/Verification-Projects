module counter_top;
    
    bit clk;
    always #5 clk = ~clk;
    
    counter_if intf(clk);
    
    counter dut (
        .clk(intf.clk),
        .rst_n(intf.rst_n),
        .load_n(intf.load_n),
        .up_down(intf.up_down),
        .ce(intf.ce),
        .data_load(intf.data_load),
        .count_out(intf.count_out),
        .max_count(intf.max_count),
        .zero(intf.zero)
    );
    
    counter_tb tb(.vif(intf.TB));
    counter_monitor mon(.vif(intf.MONITOR));
    
    // Bind SVA to DUT
    bind counter counter_sva binding_inst(.vif(intf.SVA));
    
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_top);
        #500 $finish;
    end
    
endmodule

/*
module counter_top;

    localparam WIDTH = 4;

    // Interface instance
    counter_if #(WIDTH) intf();

    // DUT instance
    counter #(.WIDTH(WIDTH)) dut (
        .clk      (intf.clk),
        .rst_n    (intf.rst_n),
        .load_n   (intf.load_n),
        .up_down  (intf.up_down),
        .ce       (intf.ce),
        .data_load(intf.data_load),
        .count_out(intf.count_out),
        .max_count(intf.max_count),
        .zero     (intf.zero)
    );

    // SVA instance with WIDTH passed
    counter_sva #(.WIDTH(WIDTH)) sva_inst (.vif(intf));

    // Clock generator
    initial begin
        intf.clk = 0;
        forever #5 intf.clk = ~intf.clk;
    end

endmodule
*/

//Guide lines:
// 1. Generate the clock
// 2. instantiate the interface, and pass the clock
// 3. instantiate the tb, DUT, monitor, and pass the interface
// 4. bind the SVA module to the design, and pass the interface

