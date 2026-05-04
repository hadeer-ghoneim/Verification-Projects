package RAM_seq_item_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_seq_item extends uvm_sequence_item;
    `uvm_object_utils(RAM_seq_item)

    // Operation types matching SPI protocol
    typedef enum bit [1:0] {
        SET_ADDR  = 2'b00,
        WRITE     = 2'b01,
        READ_ADDR = 2'b10,
        READ_DATA = 2'b11
    } ram_op_t;
    
    rand ram_op_t operation;
    rand bit [7:0] address;
    rand bit [7:0] write_data;
    bit [7:0] read_data;
    rand bit rst_n;
    rand bit rx_valid;
    
    // SPI frame data
    logic [9:0] din;
    logic [7:0] dout, dout_ref;
    logic tx_valid, tx_valid_ref;

    function new(string name = "RAM_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "Op: %s, Addr: 0x%02h, WrData: 0x%02h, RdData: 0x%02h, RST: %0b, RX_VALID: %0b", 
            operation.name(), address, write_data, read_data, rst_n, rx_valid
        );
    endfunction

    function string convert2string_stimulus();
        return $sformatf(
            "rst_n=%0b, rx_valid=%b, din=0x%03h (Op: %s)",
            rst_n, rx_valid, din, operation.name()
        );
    endfunction

    // Constraints for SPI_Wrapper integration
    constraint c_reset_low_prob { rst_n dist { 0 := 5, 1 := 95 };}
    constraint c_rx_valid_low_prob { rx_valid dist { 0 := 70, 1 := 30 };}
    constraint valid_addr { address inside {[0:255]}; }
    constraint valid_data { write_data inside {[0:255]}; }
    
    // Generate din based on operation for SPI protocol
    function void post_randomize();
        case(operation)
            SET_ADDR:  din = {2'b00, address};
            WRITE:     din = {2'b01, write_data};
            READ_ADDR: din = {2'b10, address};
            READ_DATA: din = {2'b11, 8'h00};
        endcase
    endfunction

endclass
endpackage