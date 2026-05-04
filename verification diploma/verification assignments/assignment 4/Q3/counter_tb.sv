module counter_tb(counter_if.TB vif);
    
    initial begin
        // Initialize signals
        vif.rst_n = 1'b1;
        vif.load_n = 1'b1;
        vif.up_down = 1'b1;
        vif.ce = 1'b0;
        vif.data_load = 4'b0;
        
        // Apply reset
        #15 vif.rst_n = 1'b0;
        #20 vif.rst_n = 1'b1;
        
        // Test load functionality
        #10 vif.data_load = 4'b1010;
        vif.load_n = 1'b0;
        #10 vif.load_n = 1'b1;
        
        // Test increment
        #10 vif.ce = 1'b1;
        vif.up_down = 1'b1;
        #50 vif.ce = 1'b0;
        
        // Test decrement
        #10 vif.ce = 1'b1;
        vif.up_down = 1'b0;
        #50 vif.ce = 1'b0;
        
        // Test boundary conditions
        #10 vif.load_n = 1'b0;
        vif.data_load = 4'b1111; // Max value
        #10 vif.load_n = 1'b1;
        #10 vif.ce = 1'b1;
        vif.up_down = 1'b1;
        #10 vif.ce = 1'b0;
        
        #10 vif.load_n = 1'b0;
        vif.data_load = 4'b0000; // Zero value
        #10 vif.load_n = 1'b1;
        #10 vif.ce = 1'b1;
        vif.up_down = 1'b0;
        #10 vif.ce = 1'b0;
        
        // Finish simulation
        #100 $finish;
    end
    
endmodule

/*
// counter_tb.sv
module counter_tb #(parameter WIDTH = 4) (counter_if.TB vif);

    import question_2_pkg::*;

    question_2_class test_obj;
    int test_case = 0;

    // Specific test sequences to ensure full coverage
    task test_reset();
        test_case++;
        $display("Test Case %0d: Testing Reset", test_case);
        vif.rst_n = 1'b0;
        vif.load_n = 1'b1;
        vif.up_down = 1'b1;
        vif.ce = 1'b0;
        vif.data_load = 0;
        repeat (5) @(negedge vif.clk);
        vif.rst_n = 1'b1;
        @(negedge vif.clk);
    endtask

    task test_load();
        test_case++;
        $display("Test Case %0d: Testing Load", test_case);
        vif.rst_n = 1'b1;
        vif.load_n = 1'b0; // Activate load
        vif.ce = 1'b0;
        vif.data_load = 4'b1010; // Specific value
        @(negedge vif.clk);
        vif.load_n = 1'b1; // Deactivate load
        @(negedge vif.clk);
    endtask

    task test_increment();
        test_case++;
        $display("Test Case %0d: Testing Increment", test_case);
        vif.rst_n = 1'b1;
        vif.load_n = 1'b1;
        vif.up_down = 1'b1; // Increment mode
        vif.ce = 1'b1; // Enable counting
        vif.data_load = 4'b0100;
        repeat (5) @(negedge vif.clk);
        vif.ce = 1'b0;
        @(negedge vif.clk);
    endtask

    task test_decrement();
        test_case++;
        $display("Test Case %0d: Testing Decrement", test_case);
        vif.rst_n = 1'b1;
        vif.load_n = 1'b1;
        vif.up_down = 1'b0; // Decrement mode
        vif.ce = 1'b1; // Enable counting
        vif.data_load = 4'b1100;
        repeat (5) @(negedge vif.clk);
        vif.ce = 1'b0;
        @(negedge vif.clk);
    endtask

    task test_boundary_conditions();
        test_case++;
        $display("Test Case %0d: Testing Boundary Conditions", test_case);
        
        // Test reaching maximum count
        vif.rst_n = 1'b1;
        vif.load_n = 1'b0;
        vif.data_load = 4'b1110; // One less than max
        @(negedge vif.clk);
        vif.load_n = 1'b1;
        vif.up_down = 1'b1;
        vif.ce = 1'b1;
        @(negedge vif.clk); // Should reach max count (15)
        @(negedge vif.clk); // Should wrap around if implemented
        
        // Test reaching zero
        vif.load_n = 1'b0;
        vif.data_load = 4'b0001; // One more than zero
        @(negedge vif.clk);
        vif.load_n = 1'b1;
        vif.up_down = 1'b0;
        @(negedge vif.clk); // Should reach zero
    endtask

    initial begin
        test_obj = new();
        
        // Initialize signals
        vif.rst_n = 1'b1;
        vif.load_n = 1'b1;
        vif.up_down = 1'b1;
        vif.ce = 1'b0;
        vif.data_load = 0;
        
        // Wait for initial reset
        #10;
        
        // Execute specific test sequences
        test_reset();
        test_load();
        test_increment();
        test_decrement();
        test_boundary_conditions();
        
        // Generate additional random stimuli for full coverage
        $display("Starting random stimulus generation for coverage");
        repeat (50) begin
            @(negedge vif.clk);
            assert(test_obj.randomize());
            
            vif.rst_n = test_obj.rst_n_class;
            vif.load_n = test_obj.load_n_class;
            vif.up_down = test_obj.up_down_class;
            vif.ce = test_obj.ce_class;
            vif.data_load = test_obj.data_load_class;
        end
        
        // Finish simulation
        $display("All tests completed");
        #100 $finish;
    end

endmodule
*/