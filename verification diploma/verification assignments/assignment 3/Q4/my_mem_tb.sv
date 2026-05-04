import mem_pkg::*;

module my_mem_tb;

  // ----------------------
  // DUT Signals
  // ----------------------
  logic clk;
  logic write;
  logic read;
  logic [7:0] data_in;
  logic [15:0] address;
  logic [7:0] data_out;

  // ----------------------
  // DUT Instantiation
  // ----------------------
  my_mem dut (
    .clk(clk),
    .write(write),
    .read(read),
    .data_in(data_in),
    .address(address),
    .data_out(data_out)
  );

  // ----------------------
  // Clock Generation
  // ----------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns clock period
  end

  // ----------------------
  // Initial Block
  // ----------------------
  initial begin
    // Initialize control signals
    write = 0;
    read = 0;
    data_in = 0;
    address = 0;

    // 1. Generate stimulus
    stimulus_gen();

    // 2. Populate golden model
    golden_model();

    // 3. Write Phase
    $display("Starting Write Phase...");
    for (int i = 0; i < TESTS; i++) begin
      @(negedge clk);
      address = address_array[i];
      data_in = data_to_write_array[i];
      write = 1;
      read = 0;

      @(posedge clk); // Wait for write to complete
    end
    write = 0;

    // 4. Read Phase and Self-Check
    $display("Starting Read Phase...");
    for (int i = 0; i < TESTS; i++) begin
      @(negedge clk);
      address = address_array[i];
      write = 0;
      read = 1;

      @(posedge clk); // Wait for read to complete
      check9Bits(address, {~^data_out, data_out}); // Includes parity check
      data_read_queue.push_back({~^data_out, data_out});
    end
    read = 0;

    // 5. Display Read Data from Queue
    $display("Read Data Queue:");
    while (data_read_queue.size() > 0) begin
      static bit [8:0] temp = data_read_queue.pop_front();
      $display("Data from queue: %0h", temp);
    end

    // 6. Final Report
    $display("Simulation Completed.");
    $display("Correct Count = %0d", correct_count);
    $display("Error Count   = %0d", error_count);

    $stop;
  end

endmodule
