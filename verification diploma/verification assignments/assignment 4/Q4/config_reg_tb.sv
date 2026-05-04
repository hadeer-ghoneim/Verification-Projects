module config_reg_tb;
    logic clk, reset, write;
    logic [15:0] data_in;
    logic [2:0] address;
    logic [15:0] data_out;
    
    config_reg dut(.*);
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Enum for register addresses
    typedef enum logic [2:0] {
        ADC0_REG = 3'd0,
        ADC1_REG = 3'd1,
        TEMP_SENSOR0_REG = 3'd2,
        TEMP_SENSOR1_REG = 3'd3,
        ANALOG_TEST = 3'd4,
        DIGITAL_TEST = 3'd5,
        AMP_GAIN = 3'd6,
        DIGITAL_CONFIG = 3'd7
    } reg_address_t;
    
    // Associative array for reset values
    logic [15:0] reset_assoc[string];
    
    // Test variables
    reg_address_t addr_enum;
    logic [15:0] expected_value;
    int error_count = 0;
    
    // Initialize reset values
    initial begin
        reset_assoc["adc0_reg"] = 16'hFFFF;
        reset_assoc["adc1_reg"] = 16'h0;
        reset_assoc["temp_sensor0_reg"] = 16'h0;
        reset_assoc["temp_sensor1_reg"] = 16'h0;
        reset_assoc["analog_test"] = 16'hABCD;
        reset_assoc["digital_test"] = 16'h0;
        reset_assoc["amp_gain"] = 16'h0;
        reset_assoc["digital_config"] = 16'h1;
    end
    
    // Reset task
    task apply_reset();
        reset = 1'b1;
        write = 1'b0;
        data_in = 16'h0;
        address = 3'd0;
        @(negedge clk);
        reset = 1'b0;
        @(negedge clk);
    endtask
    
    // Check result task
    task check_result(string reg_name, logic [15:0] expected, logic [15:0] actual);
        if (expected !== actual) begin
            $display("ERROR: %s - Expected: %h, Actual: %h", reg_name, expected, actual);
            error_count++;
        end else begin
            $display("PASS: %s - Value: %h", reg_name, actual);
        end
    endtask
    
    // Write task
    task write_register(reg_address_t addr, logic [15:0] data);
        @(negedge clk);
        address = addr;
        data_in = data;
        write = 1'b1;
        @(negedge clk);
        write = 1'b0;
    endtask
    
    // Read task
    task read_register(reg_address_t addr, output logic [15:0] data);
        @(negedge clk);
        address = addr;
        @(negedge clk);
        data = data_out;
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        clk = 0;
        apply_reset();
        
        // Test 1: Verify reset values
        $display("=== Testing Reset Values ===");
        for (addr_enum = addr_enum.first; addr_enum <= addr_enum.last; addr_enum = addr_enum.next) begin
            logic [15:0] read_data;
            read_register(addr_enum, read_data);
            
            case (addr_enum)
                ADC0_REG: check_result("adc0_reg", reset_assoc["adc0_reg"], read_data);
                ADC1_REG: check_result("adc1_reg", reset_assoc["adc1_reg"], read_data);
                TEMP_SENSOR0_REG: check_result("temp_sensor0_reg", reset_assoc["temp_sensor0_reg"], read_data);
                TEMP_SENSOR1_REG: check_result("temp_sensor1_reg", reset_assoc["temp_sensor1_reg"], read_data);
                ANALOG_TEST: check_result("analog_test", reset_assoc["analog_test"], read_data);
                DIGITAL_TEST: check_result("digital_test", reset_assoc["digital_test"], read_data);
                AMP_GAIN: check_result("amp_gain", reset_assoc["amp_gain"], read_data);
                DIGITAL_CONFIG: check_result("digital_config", reset_assoc["digital_config"], read_data);
            endcase
        end
        
        // Test 2: Basic read/write test
        $display("=== Testing Read/Write Functionality ===");
        for (addr_enum = addr_enum.first; addr_enum <= addr_enum.last; addr_enum = addr_enum.next) begin
           static logic [15:0] write_data = 16'hA5A5;
            logic [15:0] read_data;
            
            write_register(addr_enum, write_data);
            read_register(addr_enum, read_data);
            
            case (addr_enum)
                ADC0_REG: check_result("adc0_reg write", write_data, read_data);
                ADC1_REG: check_result("adc1_reg write", write_data, read_data);
                TEMP_SENSOR0_REG: check_result("temp_sensor0_reg write", write_data, read_data);
                TEMP_SENSOR1_REG: check_result("temp_sensor1_reg write", write_data, read_data);
                ANALOG_TEST: check_result("analog_test write", write_data, read_data);
                DIGITAL_TEST: check_result("digital_test write", write_data, read_data);
                AMP_GAIN: check_result("amp_gain write", write_data, read_data);
                DIGITAL_CONFIG: check_result("digital_config write", write_data, read_data);
            endcase
        end
        
        // Test 3: Bit-level testing
        $display("=== Testing Bit-Level Writeability ===");
        for (addr_enum = addr_enum.first; addr_enum <= addr_enum.last; addr_enum = addr_enum.next) begin
            for (int bit_num = 0; bit_num < 16; bit_num++) begin
               automatic logic [15:0] test_pattern = (1 << bit_num);
                logic [15:0] read_data;
                
                write_register(addr_enum, test_pattern);
                read_register(addr_enum, read_data);
                
                if (read_data !== test_pattern) begin
                    $display("ERROR: Register %0d, Bit %0d - Written: %h, Read: %h", 
                             addr_enum, bit_num, test_pattern, read_data);
                    error_count++;
                end
            end
        end
        
        // Summary
        $display("=== Test Summary ===");
        $display("Total errors: %0d", error_count);
        if (error_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        $finish;
    end
    
    // Monitor
    initial begin
        $timeformat(-9, 0, " ns", 10);
        $monitor("Time: %t | Address: %h | Write: %b | DataIn: %h | DataOut: %h", 
                 $time, address, write, data_in, data_out);
    end
endmodule