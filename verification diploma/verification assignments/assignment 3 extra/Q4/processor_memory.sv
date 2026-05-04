module processor_memory;

  // ---------------------------------------------------
  // Parameters
  // ---------------------------------------------------
  localparam int WORD_WIDTH     = 24;          // Each word is 24 bits
  localparam int ADDRESS_SPACE  = 1 << 20;     // 2^20 addresses (20-bit address)
  localparam int RESET_ADDR     = 20'h00000;   // Reset starts at address 0
  localparam int PROGRAM_START  = 20'h00400;   // Program starts at address 0x400
  localparam int ISR_ADDR       = 20'hFFFFF;   // ISR at max possible address (2^20 - 1)

  // ---------------------------------------------------
  // Memory Declaration - Associative Array
  // ---------------------------------------------------
  logic [WORD_WIDTH-1:0] memory [int]; 
  // Key: address (int), Value: 24-bit word

  // ---------------------------------------------------
  // Initialization
  // ---------------------------------------------------
  initial begin
    // Fill memory with given instructions
    memory[RESET_ADDR]    = 24'hA50400; // Reset instruction
    memory[PROGRAM_START] = 24'h123456; // Instruction 1
    memory[PROGRAM_START + 1] = 24'h789ABC; // Instruction 2
    memory[ISR_ADDR]      = 24'h0F1E2D; // ISR instruction

    // Display the total number of elements in the array
    $display("------------------------------------------------");
    $display("Memory Initialization Complete!");
    $display("Number of elements stored in memory = %0d", memory.num());
    $display("------------------------------------------------");

    // Display all memory contents using foreach
    foreach (memory[address]) begin
      $display("Address: 0x%05h | Data: 0x%06h", address, memory[address]);
    end

    $display("------------------------------------------------");
    $stop;
  end

endmodule
