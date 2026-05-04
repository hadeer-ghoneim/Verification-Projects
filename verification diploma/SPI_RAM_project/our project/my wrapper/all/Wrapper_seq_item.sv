package sequence_wrapper_item;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    class SPI_Wrapper_seq_item extends uvm_sequence_item;
        `uvm_object_utils(SPI_Wrapper_seq_item)
        
        // Operation types for both SPI and RAM
        typedef enum bit [1:0] {
            SET_ADDR  = 2'b00,
            WRITE     = 2'b01,
            READ_ADDR = 2'b10,
            READ_DATA = 2'b11
        } op_type_e;
        
        rand op_type_e operation;
        rand bit [7:0] address;
        rand bit [7:0] data;
        bit [7:0] read_data;
        rand bit rst_n;
        
        // SPI frame (11 bits total)
        rand bit [10:0] spi_frame;
        
        // Constraints
        constraint valid_addr { address inside {[0:255]}; }
        constraint valid_data { data inside {[0:255]}; }
        constraint rst_c { rst_n dist {1 := 95, 0 := 5}; }
        
        // SPI frame constraint based on operation
        constraint spi_frame_c {
            solve operation before spi_frame;
            if (operation == SET_ADDR) {
                spi_frame[10:9] == 2'b00;
                spi_frame[7:0] == address;
            }
            if (operation == WRITE) {
                spi_frame[10:9] == 2'b01;
                spi_frame[7:0] == data;
            }
            if (operation == READ_ADDR) {
                spi_frame[10:9] == 2'b10;
                spi_frame[7:0] == address;
            }
            if (operation == READ_DATA) {
                spi_frame[10:9] == 2'b11;
                spi_frame[7:0] == 8'h00;  // Dummy data for read; actual read_data filled post-randomize if needed
            }
        }
        
        function new(string name = "SPI_Wrapper_seq_item");
            super.new(name);
        endfunction
        
        function string convert2string();
            return $sformatf("Operation: %s, Addr: 0x%02h, Data: 0x%02h, Read_Data: 0x%02h, RST: %0b, SPI_Frame: %b",
                            operation.name(), address, data, read_data, rst_n, spi_frame);
        endfunction
        
        // Optional: Post-randomize to set read_data for read ops (simulate response)
        function void post_randomize();
            if (operation inside {READ_ADDR, READ_DATA}) begin
                // Stub: Set dummy read_data; in real test, get from scoreboard/model
                read_data = 8'hAA;  // Example; integrate with RAM model later
            end
        endfunction
    endclass

endpackage
/*
package sequence_wrapper_item;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    class SPI_Wrapper_seq_item extends uvm_sequence_item;
        `uvm_object_utils(SPI_Wrapper_seq_item)
    
    // Signals
    rand bit rst_n;
    rand bit SS_n;
    rand bit MOSI;
    bit MISO;
    
    // Control fields
    rand operation_t current_op;
    rand operation_t next_op;
    rand bit [7:0] address;
    rand bit [7:0] write_data;
    rand bit [7:0] read_data;
    
    // Timing and sequence control
    rand int cycle_count;
    rand int ssn_high_cycle;
    rand bit is_read_data_phase;
    rand bit [2:0] bit_counter;
    rand bit [10:0] mosi_shift_reg;
    
    // Probability control for randomized sequences
    rand bit sequence_type; // 0: write-only, 1: read-only, 2: mixed
    rand bit [1:0] operation_flow;
    

    // Operation types
    typedef enum bit [1:0] {
        WRITE_ADDR  = 2'b00,
        WRITE_DATA  = 2'b01,
        READ_ADDR   = 2'b10,
        READ_DATA   = 2'b11
    } operation_t;
 
    // Constraint 1: Reset deasserted most of the time
    constraint rst_constraint {
        rst_n dist {1 := 95, 0 := 5};
    }
    
    // Constraint 2: SS_n timing - high for 1 cycle every 13/23 cycles
    constraint ssn_timing_constraint {
        cycle_count inside {[0:22]};
        if (is_read_data_phase) {
            ssn_high_cycle == 22; // Every 23 cycles for read data
        } else {
            ssn_high_cycle == 12; // Every 13 cycles for other cases
        }
        SS_n == (cycle_count == ssn_high_cycle);
    }
    
    // Constraint 3: Valid command combinations for first 3 bits after SS_n falls
    constraint valid_cmd_constraint {
        mosi_shift_reg[10:8] inside {3'b000, 3'b001, 3'b110, 3'b111};
    }
    
    // Operation distribution based on sequence type
    constraint operation_distribution {
        solve sequence_type before current_op, next_op;
        
        if (sequence_type == 0) { // Write-only sequence
            // Constraint 4: Write Address followed by Write Address or Write Data
            current_op inside {WRITE_ADDR, WRITE_DATA};
            if (current_op == WRITE_ADDR) {
                next_op inside {WRITE_ADDR, WRITE_DATA};
            } else { // WRITE_DATA
                next_op inside {WRITE_ADDR, WRITE_DATA};
            }
        }
        else if (sequence_type == 1) { // Read-only sequence  
            // Constraint 5: Read Address followed by Read Data, then Read Address
            current_op inside {READ_ADDR, READ_DATA};
            if (current_op == READ_ADDR) {
                next_op == READ_DATA;
            } else { // READ_DATA
                next_op == READ_ADDR;
            }
        }
        else { // Randomized read/write sequence
            // Constraint 6: Mixed sequence with probability distribution
            current_op inside {WRITE_ADDR, WRITE_DATA, READ_ADDR, READ_DATA};
            
            if (current_op == WRITE_ADDR) {
                next_op inside {WRITE_ADDR, WRITE_DATA};
            }
            else if (current_op == WRITE_DATA) {
                operation_flow dist {
                    2'b00 := 60, // 60% → Read Address
                    2'b01 := 40  // 40% → Write Address
                };
                if (operation_flow == 2'b00) next_op == READ_ADDR;
                else next_op == WRITE_ADDR;
            }
            else if (current_op == READ_ADDR) {
                next_op == READ_DATA;
            }
            else { // READ_DATA
                operation_flow dist {
                    2'b10 := 60, // 60% → Write Address  
                    2'b11 := 40  // 40% → Read Address
                };
                if (operation_flow == 2'b10) next_op == WRITE_ADDR;
                else next_op == READ_ADDR;
            }
        }
    }
    
    // Data constraints
    constraint data_constraints {
        address inside {[0:255]};
        write_data inside {[0:255]};
        read_data inside {[0:255]};
    }
    
    // Bit counter constraint for serial transmission
    constraint bit_counter_constraint {
        bit_counter inside {[0:10]};
    }
    
    function new(string name = "spi_wrapper_seq_item");
        super.new(name);
    endfunction
    
    function void pre_randomize();
        // Initialize cycle count for SS_n timing
        if (cycle_count >= (is_read_data_phase ? 22 : 12)) begin
            cycle_count = 0;
        end
    endfunction
    
    function void post_randomize();
        // Update MOSI based on current bit position and shift register
        if (bit_counter <= 10) begin
            MOSI = mosi_shift_reg[10 - bit_counter];
        end
        
        // Update is_read_data_phase based on operation
        is_read_data_phase = (current_op == READ_DATA);
        
        // Increment cycle count for next transaction
        cycle_count++;
        
        // Update MISO for read operations
        if (current_op == READ_DATA && bit_counter >= 3) begin
            MISO = read_data[7 - (bit_counter - 3)];
        end
    endfunction
    
    // Helper function to get operation from command bits
    function operation_t get_op_from_cmd(bit [2:0] cmd_bits);
        case(cmd_bits)
            3'b000: return WRITE_ADDR;
            3'b001: return WRITE_DATA; 
            3'b110: return READ_ADDR;
            3'b111: return READ_DATA;
            default: return WRITE_ADDR;
        endcase
    endfunction
    
    // Convert to string for debugging
    function string convert2string();
        string op_str;
        case(current_op)
            WRITE_ADDR: op_str = "WRITE_ADDR";
            WRITE_DATA: op_str = "WRITE_DATA";
            READ_ADDR:  op_str = "READ_ADDR";
            READ_DATA:  op_str = "READ_DATA";
        endcase
        
        return $sformatf(
            "RST: %0b, SS_n: %0b, OP: %s, Addr: 0x%02h, WrData: 0x%02h, RdData: 0x%02h, Cycle: %0d, BitCnt: %0d",
            rst_n, SS_n, op_str, address, write_data, read_data, cycle_count, bit_counter
        );
    endfunction

endclass
endpackage

*/