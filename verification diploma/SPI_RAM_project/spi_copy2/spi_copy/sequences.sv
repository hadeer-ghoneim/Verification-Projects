// package SPI_sequence_pkg;
//     import uvm_pkg::*;
//     import SPI_seq_item_pkg::*;
//     `include "uvm_macros.svh"

// class spi_slave_base_seq extends uvm_sequence#(spi_slave_seq_item);
//   `uvm_object_utils(spi_slave_base_seq)
  
//   function new(string name = "spi_slave_base_seq");
//     super.new(name);
//   endfunction
// endclass

// class reset_sequence extends spi_slave_base_seq;
//   `uvm_object_utils(reset_sequence)
  
//   function new(string name = "reset_sequence");
//     super.new(name);
//   endfunction
  
//   task body();
//     spi_slave_seq_item item;
    
//     `uvm_info(get_type_name(), "Starting reset sequence", UVM_LOW)
    
//     // Assert reset
//     item = spi_slave_seq_item::type_id::create("item");
//     start_item(item);
//     assert(item.randomize() with {rst_n == 0; SS_n == 1;});
//     finish_item(item);
    
//     // Hold reset
//     repeat(3) begin
//       item = spi_slave_seq_item::type_id::create("item");
//       start_item(item);
//       assert(item.randomize() with {rst_n == 0;});
//       finish_item(item);
//     end
    
//     // Deassert reset
//     item = spi_slave_seq_item::type_id::create("item");
//     start_item(item);
//     assert(item.randomize() with {rst_n == 1; SS_n == 1;});
//     finish_item(item);
    
//     `uvm_info(get_type_name(), "Reset sequence completed", UVM_LOW)
//   endtask
// endclass

// class main_sequence extends spi_slave_base_seq;
//   `uvm_object_utils(main_sequence)
  
//   int num_transactions = 200;
//   int cycle_count = 0;
//   bit in_transaction = 0;
  
//   function new(string name = "main_sequence");
//     super.new(name);
//   endfunction
  
//   task body();
//     spi_slave_seq_item item;
    
//     `uvm_info(get_type_name(), "Starting main sequence", UVM_LOW)
    
//     repeat(num_transactions) begin
//       item = spi_slave_seq_item::type_id::create("item");
//       start_item(item);
      
//       if (!item.randomize() with {
//         // Ensure all command types are generated
//         MOSI_data[10:8] dist {
//           3'b000 := 25,  // Write Address
//           3'b001 := 25,  // Write Data  
//           3'b110 := 25,  // Read Address
//           3'b111 := 25   // Read Data
//         };
//       }) begin
//         `uvm_error(get_type_name(), "Randomization failed")
//       end
      
//       // Implement SS_n timing: 13 cycles normal, 23 cycles read data
//       if (item.MOSI_data[10:8] == 3'b111) begin // READ_DATA
//         if (cycle_count < 22 && in_transaction) begin
//           item.SS_n = 0;
//           cycle_count++;
//         end else begin
//           item.SS_n = 1;
//           cycle_count = 0;
//           in_transaction = 0;
//         end
//       end else begin // Other commands
//         if (cycle_count < 12 && in_transaction) begin
//           item.SS_n = 0;
//           cycle_count++;
//         end else begin
//           item.SS_n = 1;
//           cycle_count = 0;
//           in_transaction = 0;
//         end
//       end
      
//       // Start new transaction if SS_n is low
//       if (!item.SS_n) in_transaction = 1;
      
//       finish_item(item);
//     end
    
//     `uvm_info(get_type_name(), "Main sequence completed", UVM_LOW)
//   endtask
// endclass
// endpackage