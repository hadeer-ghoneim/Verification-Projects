module ALU_tb;

    reg clk;
    reg reset;
    reg [1:0] Opcode;
    reg signed [3:0] A;
    reg signed [3:0] B;
    wire signed [4:0] C;

    // Instantiate DUT
    ALU DUT (
        .clk(clk),
        .reset(reset),
        .Opcode(Opcode),
        .A(A),
        .B(B),
        .C(C)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Covergroup definition
    covergroup opcode_cg @(posedge clk);
        option.per_instance = 1;
        coverpoint Opcode {
            bins add_op = {2'b00};
            bins sub_op = {2'b01};
            bins not_a_op = {2'b10};
            bins red_or_op = {2'b11};
        }
    endgroup
    
    opcode_cg opcode_cov;

    // Stimulus
    initial begin
        opcode_cov = new();
        
        reset = 1;
        Opcode = 2'b00;
        A = 0;
        B = 0;
        @(posedge clk);
        reset = 0;
        @(posedge clk); // Wait one more cycle after reset

        // ==============================
        // Test ADD Operation
        // ==============================
        Opcode = 2'b00; A = 4'sd3; B = 4'sd2; 
        @(posedge clk); // Wait for output to be registered
        assert(C == 5'sd5) else $error("ADD FAILED: Expected 5, got %d", C);

        Opcode = 2'b00; A = -4'sd3; B = 4'sd2; 
        @(posedge clk);
        assert(C == -5'sd1) else $error("ADD FAILED: Expected -1, got %d", C);

        // ==============================
        // Test SUB Operation
        // ==============================
        Opcode = 2'b01; A = 4'sd5; B = 4'sd2; 
        @(posedge clk);
        assert(C == 5'sd3) else $error("SUB FAILED: Expected 3, got %d", C);

        Opcode = 2'b01; A = -4'sd3; B = 4'sd2; 
        @(posedge clk);
        assert(C == -5'sd5) else $error("SUB FAILED: Expected -5, got %d", C);

        // ==============================
        // Test NOT_A Operation
        // ==============================
        Opcode = 2'b10; A = 4'b1010; B = 0; 
        @(posedge clk);
        assert(C == 5'b10101) else $error("NOT_A FAILED: Expected 10101, got %b", C);

        Opcode = 2'b10; A = 4'b0101; B = 0; 
        @(posedge clk);
        assert(C == 5'b11010) else $error("NOT_A FAILED: Expected 11010, got %b", C);

        // ==============================
        // Test Reduction OR Operation
        // ==============================
        Opcode = 2'b11; A = 0; B = 4'b0000; 
        @(posedge clk);
        assert(C == 5'd0) else $error("RED_OR FAILED: Expected 0, got %d", C);

        Opcode = 2'b11; A = 0; B = 4'b1010; 
        @(posedge clk);
        assert(C == 5'd1) else $error("RED_OR FAILED: Expected 1, got %d", C);

        // ==============================
        // Test Reset Behavior
        // ==============================
        reset = 1; 
        @(posedge clk);
        assert(C == 5'd0) else $error("RESET FAILED: Expected 0, got %d", C);
        reset = 0; 
        @(posedge clk);

        // ==============================
        // Test all opcodes to ensure 100% coverage
        // ==============================
        // Test ADD with edge cases
        Opcode = 2'b00; A = 4'sd7; B = 4'sd7; 
        @(posedge clk);
        assert(C == 5'sd14) else $error("ADD edge case failed");

        // Test SUB with edge cases  
        Opcode = 2'b01; A = -4'sd8; B = -4'sd8;
        @(posedge clk);
        assert(C == 5'sd0) else $error("SUB edge case failed");

        // Test NOT_A with all bits
        Opcode = 2'b10; A = 4'b1111;
        @(posedge clk);
        assert(C == 5'b10000) else $error("NOT_A edge case failed");

        // Test RED_OR with all 1s
        Opcode = 2'b11; B = 4'b1111;
        @(posedge clk);
        assert(C == 5'd1) else $error("RED_OR edge case failed");

        // Wait for coverage collection
        #20;
        $display("All tests completed successfully!");
        $display("Code coverage: %0f%%", $get_coverage());
        $display("Toggle coverage: %0f%%", $get_toggle_coverage());
        $stop;
    end

endmodule