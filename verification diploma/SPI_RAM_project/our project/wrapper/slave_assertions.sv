module spi_slave_assertions(
  input clk,
  input rst_n,
  input MOSI,
  input SS_n,
  input MISO,
  input rx_valid,
  input [9:0] rx_data,
  input [2:0] current_state,
  input confirm_add,
  input [3:0] counter,
  input [7:0] tx_data,
  input tx_valid
);

  // Parameter definitions for FSM states - MATCHING SLAVE DESIGN
  parameter IDLE = 3'b000;
  parameter WRITE = 3'b001;      // Note: Different order than original
  parameter CHK_CMD = 3'b010;
  parameter READ_ADD = 3'b011;
  parameter READ_DATA = 3'b100;

  // ============================================================
  // Assertion 1: Reset behavior - outputs must be cleared
  // ============================================================
  property reset_outputs_p;
    @(posedge clk) (!rst_n) |-> (MISO == 0 && rx_valid == 0 && rx_data == 0 && counter == 0 && confirm_add == 0);
  endproperty
  
  assert_reset_outputs: assert property (reset_outputs_p)
    else $error("ASSERTION FAILED: Outputs not cleared during reset - MISO=%b, rx_valid=%b, rx_data=%h, counter=%d, confirm_add=%b", 
                MISO, rx_valid, rx_data, counter, confirm_add);
  
  // ============================================================
  // Assertion 2: rx_valid timing - based on counter value
  // ============================================================
  
  // rx_valid should assert when counter reaches 10
  property rx_valid_timing_p;
    @(posedge clk) disable iff (!rst_n)
    (counter == 10 && current_state inside {WRITE, READ_ADD, READ_DATA}) |-> ##1 rx_valid;
  endproperty
  
  assert_rx_valid_timing: assert property (rx_valid_timing_p)
    else $error("ASSERTION FAILED: rx_valid did not assert after counter reached 10");
  
  // rx_valid should be one cycle pulse
  property rx_valid_one_cycle_p;
    @(posedge clk) disable iff (!rst_n)
    (rx_valid) |=> !rx_valid;
  endproperty
  
  assert_rx_valid_pulse: assert property (rx_valid_one_cycle_p)
    else $error("ASSERTION FAILED: rx_valid remained high for more than one cycle");

  // ============================================================
  // Assertion 3: FSM Transition Checks
  // ============================================================

  // 3a: IDLE to CHK_CMD transition when SS_n falls
  property idle_to_chk_cmd_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == IDLE && $fell(SS_n)) |=> (current_state == CHK_CMD);
  endproperty
  
  assert_idle_to_chk_cmd: assert property (idle_to_chk_cmd_p)
    else $error("FSM ASSERTION FAILED: IDLE to CHK_CMD transition violated");
  
  // 3b: CHK_CMD to WRITE (when MOSI is 0 - first bit indicates write)
  property chk_cmd_to_write_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && !MOSI) 
    |=> (current_state == WRITE);
  endproperty
  
  assert_chk_cmd_to_write: assert property (chk_cmd_to_write_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to WRITE transition violated");
  
  // 3c: CHK_CMD to READ_ADD (when MOSI is 1 and confirm_add is 0)
  property chk_cmd_to_read_add_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && MOSI && !confirm_add) 
    |=> (current_state == READ_ADD);
  endproperty
  
  assert_chk_cmd_to_read_add: assert property (chk_cmd_to_read_add_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_ADD transition violated");
  
  // 3d: CHK_CMD to READ_DATA (when MOSI is 1 and confirm_add is 1)
  property chk_cmd_to_read_data_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && MOSI && confirm_add) 
    |=> (current_state == READ_DATA);
  endproperty
  
  assert_chk_cmd_to_read_data: assert property (chk_cmd_to_read_data_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_DATA transition violated");
  
  // 3e: READ_ADD to READ_DATA transition when confirm_add is set
  property read_add_to_read_data_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_ADD && confirm_add) |=> (current_state == READ_DATA);
  endproperty
  
  assert_read_add_to_read_data: assert property (read_add_to_read_data_p)
    else $error("FSM ASSERTION FAILED: READ_ADD to READ_DATA transition violated");
  
  // 3f: All states to IDLE when SS_n rises
  property any_to_idle_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state inside {WRITE, READ_ADD, READ_DATA} && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_any_to_idle: assert property (any_to_idle_p)
    else $error("FSM ASSERTION FAILED: State to IDLE transition violated");

  // ============================================================
  // Assertion 4: Counter behavior
  // ============================================================
  
  // Counter should increment in WRITE, READ_ADD, and READ_DATA (when tx_valid is low)
  property counter_increment_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state inside {WRITE, READ_ADD, READ_DATA} && !SS_n && 
     (current_state != READ_DATA || !tx_valid) && counter < 10) 
    |=> (counter == $past(counter) + 1);
  endproperty
  
  assert_counter_increment: assert property (counter_increment_p)
    else $error("ASSERTION FAILED: Counter not incrementing properly");
  
  // Counter should decrement in READ_DATA when tx_valid is high
  property counter_decrement_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_DATA && tx_valid && counter >= 3 && counter <= 10) 
    |=> (counter == $past(counter) - 1);
  endproperty
  
  assert_counter_decrement: assert property (counter_decrement_p)
    else $error("ASSERTION FAILED: Counter not decrementing properly in READ_DATA with tx_valid");

  // ============================================================
  // Assertion 5: MISO behavior
  // ============================================================
  
  // MISO should output tx_data bits during READ_DATA with tx_valid
  property miso_output_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_DATA && tx_valid && counter >= 3 && counter <= 10) 
    |-> (MISO == tx_data[counter-3]);
  endproperty
  
  assert_miso_output: assert property (miso_output_p)
    else $error("ASSERTION FAILED: MISO not outputting correct tx_data bit");
  
  // MISO should be stable during non-READ_DATA operations
  property miso_stable_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state != READ_DATA) |=> $stable(MISO);
  endproperty
  
  assert_miso_stable: assert property (miso_stable_p)
    else $warning("MISO changed during non-READ_DATA state");

  // ============================================================
  // Assertion 6: confirm_add behavior
  // ============================================================
  
  // confirm_add should be set when counter reaches 10 in READ_ADD
  property confirm_add_set_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_ADD && counter == 10) |=> confirm_add;
  endproperty
  
  assert_confirm_add_set: assert property (confirm_add_set_p)
    else $error("ASSERTION FAILED: confirm_add not set after READ_ADD completion");
  
  // confirm_add should be cleared when entering READ_DATA
  property confirm_add_clear_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state == READ_DATA && counter == 10) |=> !confirm_add;
  endproperty
  
  assert_confirm_add_clear: assert property (confirm_add_clear_p)
    else $error("ASSERTION FAILED: confirm_add not cleared after READ_DATA start");

  // ============================================================
  // Assertion 7: rx_data shift behavior
  // ============================================================
  
  // rx_data should shift in MOSI data
  property rx_data_shift_p;
    @(posedge clk) disable iff (!rst_n)
    (current_state inside {WRITE, READ_ADD, READ_DATA} && !SS_n && 
     counter < 10 && (current_state != READ_DATA || !tx_valid)) 
    |=> (rx_data == {$past(rx_data[8:0]), MOSI});
  endproperty
  
  assert_rx_data_shift: assert property (rx_data_shift_p)
    else $error("ASSERTION FAILED: rx_data not shifting correctly");

endmodule