package sequence_slave_item;
`include "uvm_macros.svh"
import uvm_pkg::*;

class sequence_slave_item extends uvm_sequence_item;

    `uvm_object_utils(sequence_slave_item)

    rand logic rst_n;
    rand logic [10:0] MOSI_data;
    rand logic [7:0] tx_data;
    rand logic is_read_data;
    
    // Outputs
    logic MISO;
    logic rx_valid;
    logic [9:0] rx_data;
    logic SS_n;
    logic tx_valid;
    logic MISO_ref;
    logic rx_valid_ref;
    logic [9:0] rx_data_ref;

    // Constructor
    function new(string name = "sequence_slave_item");
        super.new(name);
    endfunction

    // Reset constraint
    constraint rst_c {
        rst_n dist {1 := 95, 0 := 5};
    }

    // Valid command combinations constraint
    constraint mosi_cmd_c {
        MOSI_data[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }

    // Command distribution constraint
    constraint cmd_dist_c {
        MOSI_data[10:8] dist {
            3'b000 := 30,  // Write Address
            3'b001 := 25,  // Write Data
            3'b110 := 25,  // Read Address
            3'b111 := 20   // Read Data
        };
    }

    function void post_randomize();
        is_read_data = (MOSI_data[10:8] == 3'b111);
        tx_valid = is_read_data;
    endfunction

endclass

endpackage