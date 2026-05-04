package mem_pkg;

  // Number of test operations
  localparam int TESTS = 100;

  // ----------------------
  // Data Structures
  // ----------------------
  // Queues arrays for stimulus
  bit [15:0] address_array[$];          // Random addresses
  bit [7:0]  data_to_write_array[$];    // Random data to be written

  // Associative array for expected read values (includes parity)
  bit [8:0] data_read_expect_assoc[int];

  // Queue for actual data read from DUT
  bit [8:0] data_read_queue[$];

  // Error and correct counters
  int error_count = 0;
  int correct_count = 0;

  // ----------------------
  // Task: Stimulus Generation
  // ----------------------
  task automatic stimulus_gen();
    $display("Generating Stimulus...");
    address_array.delete();
    data_to_write_array.delete();

    for (int i = 0; i < TESTS; i++) begin
      address_array.push_back($urandom_range(0, 65535));
      data_to_write_array.push_back($urandom_range(0, 255));
    end
  endtask

  // ----------------------
  // Task: Golden Model
  // ----------------------
  task automatic golden_model();
    $display("Populating Golden Model...");
    data_read_expect_assoc.delete();

    for (int i = 0; i < TESTS; i++) begin
      bit parity = ~^data_to_write_array[i]; // Even parity
      data_read_expect_assoc[address_array[i]] = {parity, data_to_write_array[i]};
    end
  endtask

  // ----------------------
  // Task: Check 9-bit data
  // ----------------------
  task automatic check9Bits(input bit [15:0] addr, input bit [8:0] actual_data);
    if (actual_data !== data_read_expect_assoc[addr]) begin
      $display("ERROR: Addr=%0h Expected=%0h Got=%0h", addr, data_read_expect_assoc[addr], actual_data);
      error_count++;
    end
    else begin
      $display("CORRECT: Addr=%0h Data=%0h", addr, actual_data);
      correct_count++;
    end
  endtask

endpackage
