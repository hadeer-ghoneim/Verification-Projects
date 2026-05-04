module spi_slave_assertions(
  input clk,
  input rst_n,
  input MOSI_data,
  input SS_n,
  input MISO,
  input rx_valid,
  input [9:0] rx_data,
  input [2:0] current_state
);

  // Parameter definitions for FSM states
  parameter IDLE = 3'b000;
  parameter CHK_CMD = 3'b001;
  parameter WRITE = 3'b010;
  parameter READ_ADD = 3'b011;
  parameter READ_DATA = 3'b100;

  // ============================================================
  // Assertion 1: Reset behavior - outputs must be cleared
  // ============================================================
  property reset_outputs_p;
    @(posedge clk) (!rst_n) |-> (MISO == 0 && rx_valid == 0 && rx_data == 0);
  endproperty
  
  assert_reset_outputs: assert property (reset_outputs_p)
    else $error("ASSERTION FAILED: Outputs not cleared during reset - MISO=%b, rx_valid=%b, rx_data=%h", 
                MISO, rx_valid, rx_data);
  
  // ============================================================
  // Assertion 2: rx_valid timing after valid command sequence
  // FIXED: Proper bit counting and timing check
  // ============================================================
  
  // Track complete 11-bit MOSI data reception
  int mosi_bit_count = 0;
  bit transaction_started = 0;
  
  always @(posedge clk) begin
    if (!rst_n) begin
      mosi_bit_count <= 0;
      transaction_started <= 0;
    end else begin
      // Detect transaction start (SS_n falling edge)
      if ($fell(SS_n)) begin
        transaction_started <= 1;
        mosi_bit_count <= 0;
      end
      // Count bits while SS_n is low and transaction is active
      else if (!SS_n && transaction_started) begin
        mosi_bit_count <= mosi_bit_count + 1;
      end
      // Reset on transaction end
      else if (SS_n) begin
        transaction_started <= 0;
        mosi_bit_count <= 0;
      end
    end
  end
  
  // rx_valid should assert after receiving 11 bits (at cycle 11 or 12)
  property rx_valid_timing_p;
    @(posedge clk) disable iff (!rst_n)
    (transaction_started && mosi_bit_count == 11) |-> ##[0:2] rx_valid;
  endproperty
  
  assert_rx_valid_timing: assert property (rx_valid_timing_p)
    else $error("ASSERTION FAILED: rx_valid did not assert after 11-bit MOSI data reception");
  
  // ============================================================
  // Assertion 2b: SS_n behavior validation
  // Simplified: Just check that SS_n toggles appropriately
  // ============================================================
  
  // SS_n should eventually go high after being low
  property ss_n_eventually_high_p;
    @(posedge clk) disable iff (!rst_n)
    ($fell(SS_n)) |-> ##[10:30] $rose(SS_n) [->1];
  endproperty
  
  assert_ss_n_timing: assert property (ss_n_eventually_high_p)
    else $warning("ASSERTION WARNING: SS_n did not rise after falling edge");

  // ============================================================
  // Assertion 3: FSM Transition Checks (Conditional Compilation)
  // ============================================================
`ifdef SIM
  // 3a: IDLE to CHK_CMD transition when SS_n falls
  property idle_to_chk_cmd_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == IDLE && $fell(SS_n)) |=> (current_state == CHK_CMD);
  endproperty
  
  assert_idle_to_chk_cmd: assert property (idle_to_chk_cmd_p)
    else $error("FSM ASSERTION FAILED: IDLE to CHK_CMD transition violated");
  
  // 3b: CHK_CMD to WRITE (when receiving 00x command)
  property chk_cmd_to_write_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:8] == 2'b00) 
    |=> (current_state == WRITE);
  endproperty
  
  assert_chk_cmd_to_write: assert property (chk_cmd_to_write_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to WRITE transition violated");
  
  // 3c: CHK_CMD to READ_ADD (when receiving 110 command)
  property chk_cmd_to_read_add_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:8] == 2'b10 && rx_data[7] == 0) 
    |=> (current_state == READ_ADD);
  endproperty
  
  assert_chk_cmd_to_read_add: assert property (chk_cmd_to_read_add_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_ADD transition violated");
  
  // 3d: CHK_CMD to READ_DATA (when receiving 111 command)
  property chk_cmd_to_read_data_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:7] == 3'b111) 
    |=> (current_state == READ_DATA);
  endproperty
  
  assert_chk_cmd_to_read_data: assert property (chk_cmd_to_read_data_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_DATA transition violated");
  
  // 3e: WRITE to IDLE when SS_n rises
  property write_to_idle_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == WRITE && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_write_to_idle: assert property (write_to_idle_p)
    else $error("FSM ASSERTION FAILED: WRITE to IDLE transition violated");
  
  // 3f: READ_ADD to IDLE when SS_n rises
  property read_add_to_idle_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_ADD && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_read_add_to_idle: assert property (read_add_to_idle_p)
    else $error("FSM ASSERTION FAILED: READ_ADD to IDLE transition violated");
  
  // 3g: READ_DATA to IDLE when SS_n rises
  property read_data_to_idle_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_DATA && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_read_data_to_idle: assert property (read_data_to_idle_p)
    else $error("FSM ASSERTION FAILED: READ_DATA to IDLE transition violated");
    
`endif

  // ============================================================
  // Additional Useful Assertions
  // ============================================================
  
  // MISO should be stable during non-read operations
  property miso_stable_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state != READ_DATA && !SS_n) |=> $stable(MISO);
  endproperty
  
  assert_miso_stable: assert property (miso_stable_p)
    else $warning("MISO changed during non-READ_DATA state");
  
  // rx_valid should only be high for one cycle
  property rx_valid_one_cycle_p;
    @(posedge clk) disable iff (!rst_n)
    (rx_valid) |=> !rx_valid;
  endproperty
  
  assert_rx_valid_pulse: assert property (rx_valid_one_cycle_p)
    else $warning("rx_valid remained high for more than one cycle");
  
  // SS_n behavior in IDLE: When firmly in IDLE state, SS_n should eventually be high
  property ss_n_idle_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == IDLE ##1 current_state == IDLE ##1 current_state == IDLE) |-> SS_n [->1] ;
  endproperty
  
  assert_ss_n_idle: assert property (ss_n_idle_p)
    else $warning("SS_n should be high when firmly in IDLE state");

endmodule