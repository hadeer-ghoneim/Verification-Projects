package ALSU_main_sequence_pkg;

    import ALSU_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_main_sequence extends uvm_sequence #(ALSU_seq_item);
        `uvm_object_utils(ALSU_main_sequence)

        ALSU_seq_item seq_item;
        
        int num_transactions = 10000;
        
        function new(string name = "ALSU_main_sequence");
            super.new(name);
        endfunction

        task body();
            seq_item = ALSU_seq_item::type_id::create("seq_item");
            
            // Generate random transactions
            repeat(num_transactions) begin
                start_item(seq_item);
                
                // Disable opcode sequence constraint for normal randomization
                seq_item.opcode_seq_con.constraint_mode(0);
                
                if (!seq_item.randomize()) begin
                    `uvm_error("BODY", "Randomization failed")
                end
                finish_item(seq_item);
            end

            // Generate unique opcode sequence (ALSU_12)
            `uvm_info("BODY", "Generating unique opcode sequence...", UVM_LOW)
            start_item(seq_item);
            seq_item.opcode_seq_con.constraint_mode(1);
            if (!seq_item.randomize()) begin
                `uvm_error("BODY", "Opcode sequence randomization failed")
            end
            finish_item(seq_item);

        endtask

    endclass

endpackage