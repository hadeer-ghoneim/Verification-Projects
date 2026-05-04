package sequence_wrapper_item;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequnce_ram_item::*;

class sequence_wrapper_item extends uvm_sequence_item;

    `uvm_object_utils(sequence_wrapper_item)

    sequnce_ram_item ram_item;

    // ================= Signals =================
    rand bit rst_n;
    rand bit SS_n;
    rand bit [10:0] MOSI;
    rand bit [7:0] tx_data;
    bit MISO_ref; 

    // Outputs
    bit MISO;
    bit rx_valid;
    bit [9:0] rx_data;
    bit tx_valid;

    // ================= Constraint 1 =================
    // Reset deasserted most of the time
    constraint rst_c {
        rst_n dist {1 := 95, 0 := 5};
    }

    // ================= Constraint 2 =================
    // SS_n high for one cycle every 13 cycles, except read data case (every 23 cycles)
    constraint ss_period_c {
        if (ram_item.read_data)
        SS_n dist {1 := 1, 0 := 22}; // 1 high every 23 cycles
        else
        SS_n dist {1 := 1, 0 := 12}; // 1 high every 13 cycles
    }

    // ================= Constraint 3 =================
    // Valid command combinations for the first 3 bits (MOSI[10:8])
    constraint mosi_cmd_c {
        MOSI[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }

    // Optional better coverage distribution
    constraint cmd_dist_c {
        MOSI[10:8] dist {
        3'b000 := 30,  // Write Address
        3'b001 := 25,  // Write Data
        3'b110 := 25,  // Read Address
        3'b111 := 20   // Read Data
        };
    }

     // ================= Post Randomize =================

    function void post_randomize();
        is_read_data = (MOSI[10:8] == 3'b111);
        tx_valid = is_read_data;
    endfunction

        // Constructor
        function new(string name = "sequence_wrapper_item");
            super.new(name);
        endfunction


    endclass

endpackage