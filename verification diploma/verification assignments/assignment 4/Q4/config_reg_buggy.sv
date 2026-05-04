typedef enum logic [2:0] {
    ADC0_REG = 3'd0,
    ADC1_REG = 3'd1,
    TEMP_SENSOR0_REG = 3'd2,
    TEMP_SENSOR1_REG = 3'd3,
    ANALOG_TEST = 3'd4,
    DIGITAL_TEST = 3'd5,
    AMP_GAIN = 3'd6,
    DIGITAL_CONFIG = 3'd7
} reg_names_t;


// Associative array golden model
logic [15:0] reset_assoc[string];

initial begin
    reset_assoc["ADC0_REG"]        = 16'hFFFF;
    reset_assoc["ADC1_REG"]        = 16'h0000;
    reset_assoc["TEMP_SENSOR0_REG"]= 16'h0000;
    reset_assoc["TEMP_SENSOR1_REG"]= 16'h0000;
    reset_assoc["ANALOG_TEST"]     = 16'hABCD;
    reset_assoc["DIGITAL_TEST"]    = 16'h0000;
    reset_assoc["AMP_GAIN"]        = 16'h0000;
    reset_assoc["DIGITAL_CONFIG"]  = 16'h0001;
end


module config_reg_tb;

    // DUT interface signals
    logic clk;
    logic reset;
    logic write;
    logic [2:0] address;
    logic [15:0] data_in;
    logic [15:0] data_out;

    // Enum variable
    reg_names_t reg_name;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate DUT
    config_reg_buggy dut (
        .clk(clk),
        .reset(reset),
        .write(write),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // ========================
    // TASKS
    // ========================
    
    // Reset task
    task apply_reset();
        reset = 1;
        write = 0;
        data_in = 0;
        address = 0;
        repeat(2) @(posedge clk);
        reset = 0;
        $display("INFO: Reset applied.");
    endtask

    // Task to check a single register value
    task check_register(input string reg_str, input [15:0] expected_value);
        if (data_out !== expected_value) begin
            $display("ERROR: %s mismatch! Expected=%h, Got=%h",
                      reg_str, expected_value, data_out);
        end else begin
            $display("PASS: %s value correct (%h)", reg_str, data_out);
        end
    endtask

    // Write task
    task write_register(input reg_names_t reg_addr, input [15:0] value);
        @(posedge clk);
        write = 1;
        address = reg_addr;
        data_in = value;
        @(posedge clk);
        write = 0;
    endtask

    // Read task
    task read_register(input reg_names_t reg_addr);
        @(posedge clk);
        write = 0;
        address = reg_addr;
    endtask

    // ========================
    // MAIN TEST SEQUENCE
    // ========================
    initial begin
        clk = 0;
        reset = 0;
        write = 0;
        data_in = 0;
        address = 0;

        apply_reset();

        // ---- Test reset values ----
        $display("=== Checking Reset Values ===");
        foreach (reset_assoc[key]) begin
            reg_name = reg_names_t'(reset_assoc.find_index(key));
        end

        for (reg_name = reg_names_t'(reg_name.first());
             reg_name <= reg_name.last();
             reg_name = reg_name.next()) begin
            read_register(reg_name);
            case (reg_name)
                ADC0_REG:        check_register("ADC0_REG", reset_assoc["ADC0_REG"]);
                ADC1_REG:        check_register("ADC1_REG", reset_assoc["ADC1_REG"]);
                TEMP_SENSOR0_REG:check_register("TEMP_SENSOR0_REG", reset_assoc["TEMP_SENSOR0_REG"]);
                TEMP_SENSOR1_REG:check_register("TEMP_SENSOR1_REG", reset_assoc["TEMP_SENSOR1_REG"]);
                ANALOG_TEST:     check_register("ANALOG_TEST", reset_assoc["ANALOG_TEST"]);
                DIGITAL_TEST:    check_register("DIGITAL_TEST", reset_assoc["DIGITAL_TEST"]);
                AMP_GAIN:        check_register("AMP_GAIN", reset_assoc["AMP_GAIN"]);
                DIGITAL_CONFIG:  check_register("DIGITAL_CONFIG", reset_assoc["DIGITAL_CONFIG"]);
            endcase
        end

        // ---- Write and Read test ----
        $display("=== Write and Read Test ===");
        for (reg_name = reg_name.first();
             reg_name <= reg_name.last();
             reg_name = reg_name.next()) begin
            write_register(reg_name, 16'hA5A5);
            read_register(reg_name);
            check_register($sformatf("%s", reg_name.name()), 16'hA5A5);
        end

        $display("=== Test Completed ===");
        $finish;
    end

endmodule
