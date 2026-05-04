class SPI_Wrapper_test extends uvm_test;
    `uvm_component_utils(SPI_Wrapper_test)
    
    SPI_Wrapper_env env;
    SPI_Wrapper_reset_sequence rst_seq;
    SPI_Wrapper_write_only_sequence write_seq;
    SPI_Wrapper_read_only_sequence read_seq;
    SPI_Wrapper_write_read_sequence write_read_seq;

    function new(string name = "SPI_Wrapper_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = SPI_Wrapper_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "Starting SPI Wrapper Verification", UVM_LOW)
        
        // Run reset sequence
        rst_seq = SPI_Wrapper_reset_sequence::type_id::create("rst_seq");
        rst_seq.start(env.agt.sqr);
        
        // Run write-only sequence
        write_seq = SPI_Wrapper_write_only_sequence::type_id::create("write_seq");
        write_seq.start(env.agt.sqr);
        
        // Run read-only sequence  
        read_seq = SPI_Wrapper_read_only_sequence::type_id::create("read_seq");
        read_seq.start(env.agt.sqr);
        
        // Run write-read sequence
        write_read_seq = SPI_Wrapper_write_read_sequence::type_id::create("write_read_seq");
        write_read_seq.start(env.agt.sqr);
        
        #10000;
        phase.drop_objection(this);
    endtask
    
    function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0) begin
            `uvm_info(get_type_name(), "*** SPI WRAPPER TEST PASSED ***", UVM_NONE)
        end else begin
            `uvm_info(get_type_name(), "*** SPI WRAPPER TEST FAILED ***", UVM_NONE)
        end
    endfunction
endclass