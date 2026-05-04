module counter_monitor(counter_if.MONITOR vif);
    
    initial begin
        $display("Time\t rst_n\t load_n\t ce\t up_down\t data_load\t count_out\t max_count\t zero");
        $display("==================================================================================");
    end
    
    always @(posedge vif.clk) begin
        $display("%0t\t %b\t %b\t %b\t %b\t\t %b\t %b\t %b\t\t %b",
                 $time, vif.rst_n, vif.load_n, vif.ce, vif.up_down,
                 vif.data_load, vif.count_out, vif.max_count, vif.zero);
    end
    
endmodule

/*
// counter_monitor.sv
module counter_monitor (counter_if.TEST vif);

    // This monitor only observes signals and prints transitions
    // It helps you trace DUT behavior and verify correctness manually

    // Print header once at the start of simulation
    initial begin
        $display("Time\tclk\trst_n\tload_n\tce\tup_down\tdata_load\tcount_out\tmax_count\tzero");
        $display("-------------------------------------------------------------------------------");
    end

    // Monitor process: trigger on every posedge of clk
    always @(posedge vif.clk or negedge vif.rst_n) begin
        if (!vif.rst_n) begin
            $display("[%0t]\tRESET asserted -> count_out=%0d", $time, vif.count_out);
        end else begin
            $display("[%0t]\t%b\t%b\t%b\t%b\t%b\t%0d\t%0d\t%b\t%b",
                     $time, 
                     vif.clk, 
                     vif.rst_n, 
                     vif.load_n, 
                     vif.ce, 
                     vif.up_down, 
                     vif.data_load, 
                     vif.count_out,
                     vif.max_count, 
                     vif.zero);
        end
    end

endmodule
*/
// Guide lines :
// 1. Add the modport above
// 2. Add the monitor statement in an initial block
