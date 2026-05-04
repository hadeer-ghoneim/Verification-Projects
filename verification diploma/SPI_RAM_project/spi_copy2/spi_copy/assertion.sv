module spi_slave_assertions(
  input clk,
  input rst_n,
  input MOSI,
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
    @(negedge clk) (!rst_n) |-> (MISO == 0 && rx_valid == 0 && rx_data == 0);
  endproperty
  
  assert_reset_outputs: assert property (reset_outputs_p)
    else $error("ASSERTION FAILED: Outputs not cleared during reset - MISO=%b, rx_valid=%b, rx_data=%h", 
                MISO, rx_valid, rx_data);
  
  // ============================================================
  // Assertion 2: rx_valid timing after valid command sequence
  // ============================================================
  // Track when we receive a complete 3-bit command
  bit [2:0] cmd_buffer;
  int bit_count = 0;
  bit cmd_received = 0;
  
  always @(posedge clk) begin
    if (!rst_n) begin
      bit_count <= 0;
      cmd_received <= 0;
    end else if (!SS_n) begin
      if (bit_count < 3) begin
        cmd_buffer <= {cmd_buffer[1:0], MOSI};
        bit_count <= bit_count + 1;
        if (bit_count == 2) begin
          // Check if valid command
          if (cmd_buffer[1:0] == 2'b00 && MOSI == 1'b0 ||  // 000
              cmd_buffer[1:0] == 2'b00 && MOSI == 1'b1 ||  // 001
              cmd_buffer[1:0] == 2'b11 && MOSI == 1'b0 ||  // 110
              cmd_buffer[1:0] == 2'b11 && MOSI == 1'b1) begin // 111
            cmd_received <= 1'b1;
          end
        end
      end
    end else begin
      bit_count <= 0;
      cmd_received <= 0;
    end
  end
  
  // After 10 cycles from command received, rx_valid should assert
  property rx_valid_timing_p;
    @(negedge clk) disable iff (!rst_n)
    (cmd_received && bit_count >= 10) |-> ##1 rx_valid;
  endproperty
  
  assert_rx_valid_timing: assert property (rx_valid_timing_p)
    else $error("ASSERTION FAILED: rx_valid did not assert 10 cycles after command");
  
  // SS_n should go high eventually after transaction
  property ss_n_eventually_high_p;
    @(negedge clk) disable iff (!rst_n)
    (rx_valid) |-> ##[1:5] SS_n;
  endproperty
  
  assert_ss_n_timing: assert property (ss_n_eventually_high_p)
    else $warning("ASSERTION WARNING: SS_n did not go high after rx_valid");

  // ============================================================
  // Assertion 3: FSM Transition Checks (Conditional Compilation)
  // ============================================================
`ifdef SIM
  // 3a: IDLE to CHK_CMD transition when SS_n falls
  property idle_to_chk_cmd_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == IDLE && $fell(SS_n)) |=> (current_state == CHK_CMD);
  endproperty
  
  assert_idle_to_chk_cmd: assert property (idle_to_chk_cmd_p)
    else $error("FSM ASSERTION FAILED: IDLE to CHK_CMD transition violated");
  
  // 3b: CHK_CMD to WRITE (when receiving 00x command)
  property chk_cmd_to_write_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:8] == 2'b00) 
    |=> (current_state == WRITE);
  endproperty
  
  assert_chk_cmd_to_write: assert property (chk_cmd_to_write_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to WRITE transition violated");
  
  // 3c: CHK_CMD to READ_ADD (when receiving 110 command)
  property chk_cmd_to_read_add_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:8] == 2'b10 && rx_data[7] == 0) 
    |=> (current_state == READ_ADD);
  endproperty
  
  assert_chk_cmd_to_read_add: assert property (chk_cmd_to_read_add_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_ADD transition violated");
  
  // 3d: CHK_CMD to READ_DATA (when receiving 111 command)
  property chk_cmd_to_read_data_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == CHK_CMD && !SS_n && rx_data[9:7] == 3'b111) 
    |=> (current_state == READ_DATA);
  endproperty
  
  assert_chk_cmd_to_read_data: assert property (chk_cmd_to_read_data_p)
    else $error("FSM ASSERTION FAILED: CHK_CMD to READ_DATA transition violated");
  
  // 3e: WRITE to IDLE when SS_n rises
  property write_to_idle_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == WRITE && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_write_to_idle: assert property (write_to_idle_p)
    else $error("FSM ASSERTION FAILED: WRITE to IDLE transition violated");
  
  // 3f: READ_ADD to IDLE when SS_n rises
  property read_add_to_idle_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == READ_ADD && $rose(SS_n)) |=> (current_state == IDLE);
  endproperty
  
  assert_read_add_to_idle: assert property (read_add_to_idle_p)
    else $error("FSM ASSERTION FAILED: READ_ADD to IDLE transition violated");
  
  // 3g: READ_DATA to IDLE when SS_n rises
  property read_data_to_idle_p;
    @(negedge clk) disable iff (!rst_n)
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
    @(negedge clk) disable iff (!rst_n)
    (current_state != READ_DATA && !SS_n) |=> $stable(MISO);
  endproperty
  
  assert_miso_stable: assert property (miso_stable_p)
    else $warning("MISO changed during non-READ_DATA state");
  
  // rx_valid should only be high for one cycle
  property rx_valid_one_cycle_p;
    @(negedge clk) disable iff (!rst_n)
    (rx_valid) |=> !rx_valid;
  endproperty
  
  assert_rx_valid_pulse: assert property (rx_valid_one_cycle_p)
    else $warning("rx_valid remained high for more than one cycle");
  
  // SS_n must be high when not in transaction
  property ss_n_idle_p;
    @(negedge clk) disable iff (!rst_n)
    (current_state == IDLE) |-> SS_n;
  endproperty
  
  assert_ss_n_idle: assert property (ss_n_idle_p)
    else $error("SS_n must be high in IDLE state");

endmodule