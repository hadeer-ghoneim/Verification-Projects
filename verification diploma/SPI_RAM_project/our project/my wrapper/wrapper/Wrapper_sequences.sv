// Base Sequence
class SPI_Wrapper_base_seq extends uvm_sequence #(SPI_Wrapper_seq_item);
    `uvm_object_utils(SPI_Wrapper_base_seq)
    
    function new(string name = "SPI_Wrapper_base_seq");
        super.new(name);
    endfunction
    
    task send_spi_transaction(SPI_Wrapper_seq_item item);
        start_item(item);
        finish_item(item);
    endtask
endclass

// Reset Sequence
class SPI_Wrapper_reset_sequence extends SPI_Wrapper_base_seq;
    `uvm_object_utils(SPI_Wrapper_reset_sequence)
    
    function new(string name = "SPI_Wrapper_reset_sequence");
        super.new(name);
    endfunction
    
    task body();
        SPI_Wrapper_seq_item item;
        
        `uvm_info(get_type_name(), "Starting reset sequence", UVM_MEDIUM)
        
        // Apply reset
        item = SPI_Wrapper_seq_item::type_id::create("item");
        assert(item.randomize() with {rst_n == 0;});
        send_spi_transaction(item);
        
        // Hold reset
        repeat(5) begin
            item = SPI_Wrapper_seq_item::type_id::create("item");
            assert(item.randomize() with {rst_n == 0;});
            send_spi_transaction(item);
        end
        
        // Release reset
        item = SPI_Wrapper_seq_item::type_id::create("item");
        assert(item.randomize() with {rst_n == 1;});
        send_spi_transaction(item);
        
        `uvm_info(get_type_name(), "Reset sequence completed", UVM_MEDIUM)
    endtask
endclass

// Write-only Sequence
class SPI_Wrapper_write_only_sequence extends SPI_Wrapper_base_seq;
    `uvm_object_utils(SPI_Wrapper_write_only_sequence)
    
    int num_transactions = 50;
    SPI_Wrapper_seq_item::op_type_e prev_op;
    
    function new(string name = "SPI_Wrapper_write_only_sequence");
        super.new(name);
        prev_op = SPI_Wrapper_seq_item::SET_ADDR;
    endfunction
    
    task body();
        SPI_Wrapper_seq_item item;
        
        `uvm_info(get_type_name(), "Starting write-only sequence", UVM_MEDIUM)
        
        for (int i = 0; i < num_transactions; i++) begin
            item = SPI_Wrapper_seq_item::type_id::create("item");
            
            // Constraint 4: Write-only sequence
            assert(item.randomize() with {
                rst_n == 1;
                is_write_only == 1;
                prev_operation == prev_op;
                operation inside {SET_ADDR, WRITE};
            });
            
            send_spi_transaction(item);
            prev_op = item.operation;
        end
        
        `uvm_info(get_type_name(), "Write-only sequence completed", UVM_MEDIUM)
    endtask
endclass

// Read-only Sequence
class SPI_Wrapper_read_only_sequence extends SPI_Wrapper_base_seq;
    `uvm_object_utils(SPI_Wrapper_read_only_sequence)
    
    int num_transactions = 50;
    SPI_Wrapper_seq_item::op_type_e prev_op;
    
    function new(string name = "SPI_Wrapper_read_only_sequence");
        super.new(name);
        prev_op = SPI_Wrapper_seq_item::READ_ADDR;
    endfunction
    
    task body();
        SPI_Wrapper_seq_item item;
        
        `uvm_info(get_type_name(), "Starting read-only sequence", UVM_MEDIUM)
        
        for (int i = 0; i < num_transactions; i++) begin
            item = SPI_Wrapper_seq_item::type_id::create("item");
            
            // Constraint 5: Read-only sequence
            assert(item.randomize() with {
                rst_n == 1;
                is_read_only == 1;
                prev_operation == prev_op;
                operation inside {READ_ADDR, READ_DATA};
            });
            
            send_spi_transaction(item);
            prev_op = item.operation;
        end
        
        `uvm_info(get_type_name(), "Read-only sequence completed", UVM_MEDIUM)
    endtask
endclass

// Write-read Sequence
class SPI_Wrapper_write_read_sequence extends SPI_Wrapper_base_seq;
    `uvm_object_utils(SPI_Wrapper_write_read_sequence)
    
    int num_transactions = 100;
    SPI_Wrapper_seq_item::op_type_e prev_op;
    
    function new(string name = "SPI_Wrapper_write_read_sequence");
        super.new(name);
        prev_op = SPI_Wrapper_seq_item::SET_ADDR;
    endfunction
    
    task body();
        SPI_Wrapper_seq_item item;
        
        `uvm_info(get_type_name(), "Starting write-read sequence", UVM_MEDIUM)
        
        for (int i = 0; i < num_transactions; i++) begin
            item = SPI_Wrapper_seq_item::type_id::create("item");
            
            // Constraint 6: Write-read sequence with probability distribution
            assert(item.randomize() with {
                rst_n == 1;
                is_write_read == 1;
                prev_operation == prev_op;
            });
            
            send_spi_transaction(item);
            prev_op = item.operation;
        end
        
        `uvm_info(get_type_name(), "Write-read sequence completed", UVM_MEDIUM)
    endtask
endclass