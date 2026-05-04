function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(luvm_config_db #(q10_config)::get(this , "", "CFG", q10_cfg))begin
    `uvm_fatal("build_phase","unable to get configuration object in the driver")
    end
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase)
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
    q10_vif_driver.rst_n =$random;
    q10_vif_driver.received_data = $random;
    @(negedge q10_vif_driver.clk);
    end
endtask