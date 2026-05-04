package sequence_wrapper_item;
`include "uvm_macros.svh"
import uvm_pkg::*;

class sequence_wrapper_item extends uvm_sequence_item;

    `uvm_object_utils(sequence_wrapper_item)

    // ================= Signals =================
    rand bit rst_n;
    rand bit SS_n;
    rand bit [10:0] MOSI;
    rand bit [7:0] tx_data;
    rand bit is_read_data;
    rand bit [1:0] op_type; // 00: Write Addr, 01: Write Data, 10: Read Addr, 11: Read Data
    rand bit [1:0] next_op_type;
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
        if (is_read_data)
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

    // ================= Constraint 4 =================
    // Write-only sequence rules
    constraint write_only_seq_c {
        if (op_type == 2'b00) // Write Address
        (next_op_type inside {2'b00, 2'b01}); // must follow by Write Addr or Write Data
    }

    // ================= Constraint 5 =================
    // Read-only sequence rules
    constraint read_only_seq_c {
        if (op_type == 2'b10) // Read Address
        next_op_type == 2'b11; // must follow by Read Data
        if (op_type == 2'b11) // Read Data
        next_op_type == 2'b10; // must follow by Read Address
    }

    // ================= Constraint 6 =================
    // Randomized read/write mixed sequence
    rand bit is_mixed_seq;

    constraint mixed_seq_rules {
        if (is_mixed_seq) {

        // Write Address rules
        if (op_type == 2'b00)
            next_op_type inside {2'b00, 2'b01};

        // After Write Data
        if (op_type == 2'b01)
            next_op_type dist {2'b10 := 60, 2'b00 := 40}; // 60% Read Addr, 40% Write Addr

        // Read Address
        if (op_type == 2'b10)
            next_op_type == 2'b11; // Always followed by Read Data

        // After Read Data
        if (op_type == 2'b11)
            next_op_type dist {2'b00 := 60, 2'b10 := 40}; // 60% Write Addr, 40% Read Addr
        }
    }

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