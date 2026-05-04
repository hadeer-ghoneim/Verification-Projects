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
            spi_frame[7:0] == 8'h00;
        }
    }
    
    function new(string name = "SPI_Wrapper_seq_item");
        super.new(name);
    endfunction
    
    function string convert2string();
        return $sformatf("Operation: %s, Addr: 0x%02h, Data: 0x%02h, Read_Data: 0x%02h, RST: %0b",
                        operation.name(), address, data, read_data, rst_n);
    endfunction
    
    // Helper functions
    function bit is_read_operation();
        return (operation inside {READ_ADDR, READ_DATA});
    endfunction
    
    function int get_spi_cycles();
        return (operation == READ_DATA) ? 22 : 12;
    endfunction
endclass