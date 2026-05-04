module priority_enc_tb ();

    reg [3:0] D_tb; 
    logic [1:0] Y_tb;
    reg valid_tb;
    bit clk;
    bit rst;

    priority_enc DUT_enc (clk,rst,D_tb,Y_tb,valid_tb);

    always begin
        #5 clk = ~clk;
    end

    // COUNTER_1

    task asser_reset ();
        @(negedge clk);
            D_tb = 0 ; 
            rst = 1;
            // === Assertions for reset ===
            @(posedge clk);
            assert (Y_tb == 2'b00)
                else $error("RESET ASSERTION FAILED: Expected Y=00, Got Y=%b at time %0t", Y_tb, $time);

            assert (valid_tb == 0 || valid_tb == 1'bx)
                else $error("RESET ASSERTION FAILED: Expected valid=0, Got valid=%b at time %0t", valid_tb, $time);

            rst = 0;
    endtask
    

    // COUNTER_2
    initial begin
        clk = 0; 
        rst = 1; // Assert reset at time 0
        D_tb = 4'b0000;

        repeat(2) @(posedge clk);
        rst = 0; // De-assert reset

        asser_reset();

        // CHECK_1_past_state valid was 0
        D_tb = 4'b1000;
        @(posedge clk); 
        assert(Y_tb == 2'b00) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 0) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_1
        D_tb = 4'b1000;
        @(posedge clk); 
        assert(Y_tb == 2'b00) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_2_past_state y was 00
        D_tb = 4'b0100;
        @(posedge clk);
        assert(Y_tb == 2'b00) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_2
        D_tb = 4'b0100;
        @(posedge clk);
        assert(Y_tb == 2'b01) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1100;
        @(posedge clk);
        assert(Y_tb == 2'b01) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_3_past_state y was 01
        D_tb = 4'b1110;
        @(posedge clk);
        assert(Y_tb == 2'b01) else $error("ASSERTION FAILED: D=%b, Expected Y=10, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_3
        D_tb = 4'b1110;
        @(posedge clk);
        assert(Y_tb == 2'b10) else $error("ASSERTION FAILED: D=%b, Expected Y=10, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1010;
        @(posedge clk);
        assert(Y_tb == 2'b10) else $error("ASSERTION FAILED: D=%b, Expected Y=10, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b0110;
        @(posedge clk);
        assert(Y_tb == 2'b10) else $error("ASSERTION FAILED: D=%b, Expected Y=10, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b0010;
        @(posedge clk);
        assert(Y_tb == 2'b10) else $error("ASSERTION FAILED: D=%b, Expected Y=10, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

       // CHECK_4_past_state y was 10
        D_tb = 4'b0001;
        @(posedge clk);
        assert(Y_tb == 2'b10) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_4
        D_tb = 4'b0001;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1001;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b0101;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1101;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b0011;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b0111;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1011;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1111;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=11, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_6_past_state y was 11
        D_tb = 4'b0100;
        @(posedge clk);
        assert(Y_tb == 2'b11) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        // CHECK_6
        D_tb = 4'b0100;
        @(posedge clk);
        assert(Y_tb == 2'b01) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        D_tb = 4'b1100;
        @(posedge clk);
        assert(Y_tb == 2'b01) else $error("ASSERTION FAILED: D=%b, Expected Y=01, Got Y=%b", D_tb, Y_tb);
        assert(valid_tb == 1) else $error("ASSERTION FAILED: D=%b, Expected valid=1, Got valid=%b", D_tb, valid_tb);

        $stop;
    end

endmodule