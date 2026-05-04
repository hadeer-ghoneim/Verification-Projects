import assertions_pkg::*;

module tb_complete();
    logic clk, rst;
    logic a, b, c;
    
    // Priority Encoder signals
    logic [3:0] D;
    logic [1:0] Y;
    logic valid;
    
    // 3-to-8 Decoder signals
    logic [2:0] decoder_in;
    logic [7:0] decoder_Y;
    
    // Test control flags
    logic test_assertion_1;
    logic test_assertion_2; 
    logic test_assertion_3;
    
    // Instantiate modules
    priority_enc dut_priority (
        .clk(clk),
        .rst(rst),
        .D(D),
        .Y(Y),
        .valid(valid)
    );
    
    decoder_3to8 dut_decoder (
        .clk(clk),
        .rst(rst),
        .in(decoder_in),
        .Y(decoder_Y)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Assertions - ADD DELAY FOR DECODER
    assert property (a_then_b_after_2(clk, rst, test_assertion_1, a, b))
      else $error("Assertion 1 Failed: 'a' was high, but 'b' did not go high after 2 cycles");

    assert property (a_and_b_then_c_1to3(clk, rst, test_assertion_2, a, b, c))
      else $error("Assertion 2 Failed: 'a && b' were high, but 'c' was not high within 1 to 3 cycles");

    assert property (prop_s11b(clk, rst, test_assertion_3, b))
      else $error("Assertion 3 Failed: Sequence s11b - 'b' was not low after 2 cycles");

    // Add small delay for decoder to stabilize
    property decoder_one_hot_delayed;
        @(posedge clk) disable iff (rst) ##1 $onehot(decoder_Y);
    endproperty
    assert property (decoder_one_hot_delayed)
      else $error("Assertion 4-i Failed: 'decoder_Y' is not one-hot encoded!");

    assert property (priority_encoder_valid(clk, rst, D, valid))
      else $error("Assertion 4-ii Failed: All D inputs were 0, but 'valid' was not low in the next cycle");
    
    // Test sequence
    initial begin
        integer i;
        
        // Initialize
        clk = 0;
        rst = 1;
        a = 0; b = 0; c = 0;
        D = 4'b0000;
        decoder_in = 3'b000;
        test_assertion_1 = 0;
        test_assertion_2 = 0;
        test_assertion_3 = 0;
        
        // Release reset
        #20 rst = 0;
        @(posedge clk); // Wait for first clock after reset
        
        $display("Starting directed assertion tests...");
        
        // ==================== TEST ASSERTION 4-i FIRST ====================
        $display("Testing Assertion 4-i: Decoder one-hot");
        // Test all decoder inputs first to avoid false failures
        for (i = 0; i < 8; i++) begin
            decoder_in <= i;
            @(posedge clk);
            // Wait for decoder to stabilize
            #1; // Small delay after clock edge
        end
        decoder_in <= 3'b000;
        @(posedge clk);
        #1; // Small delay after clock edge
        
        // ==================== TEST ASSERTION 4-ii ====================
        $display("Testing Assertion 4-ii: Priority encoder valid");
        D <= 4'b0000;
        @(posedge clk); // valid should be low next cycle
        @(posedge clk); // Check
        
        // ==================== TEST ASSERTION 1 ====================
        $display("Testing Assertion 1: a -> ##2 b");
        test_assertion_1 = 1;
        
        // Setup: a goes high
        a <= 1;
        @(posedge clk);
        a <= 0;
        
        // Wait 1 cycle
        @(posedge clk);
        
        // Set b high at cycle 2 (should pass)
        b <= 1;
        @(posedge clk);
        b <= 0;
        
        test_assertion_1 = 0;
        @(posedge clk);
        @(posedge clk); // Extra cycle to ensure assertion completes
        
        // ==================== TEST ASSERTION 2 ====================
        $display("Testing Assertion 2: (a && b) -> ##[1:3] c");
        test_assertion_2 = 1;
        
        // Setup: a and b go high
        a <= 1; b <= 1;
        @(posedge clk);
        
        // Set c high at cycle 1 (should pass)
        c <= 1;
        @(posedge clk);
        a <= 0; b <= 0; c <= 0;
        @(posedge clk); // Extra cycle
        
        test_assertion_2 = 0;
        @(posedge clk);
        
        // ==================== TEST ASSERTION 3 ====================
        $display("Testing Assertion 3: sequence s11b (##2 !b)");
        test_assertion_3 = 1;
        
        // Setup: b goes high
        b <= 1;
        @(posedge clk);
        @(posedge clk);
        
        // Set b low at cycle 2 (should pass)
        b <= 0;
        @(posedge clk);
        
        test_assertion_3 = 0;
        @(posedge clk);
        @(posedge clk); // Extra cycle to ensure assertion completes
        
        // ==================== RANDOM TESTS ====================
        $display("Starting 10,000 random test iterations...");
        
        // Disable assertion testing during random tests
        test_assertion_1 = 0;
        test_assertion_2 = 0;
        test_assertion_3 = 0;
        
        // Main repeat loop with 10,000 iterations
        for (i = 0; i < 10000; i++) begin
            // Randomize all inputs
            D <= $urandom;
            decoder_in <= $urandom_range(0, 7);
            a <= 0;  // Keep assertion signals low during random tests
            b <= 0;
            c <= 0;
            
            @(posedge clk);
            
            // Display progress every 1000 tests
            if (i % 1000 == 0) begin
                $display("Completed %0d random tests...", i);
            end
        end
        
        $display("10,000 test iterations completed successfully!");
        $display("All directed assertion tests should have passed.");
        #100 $finish;
    end
    
endmodule