// FSM Assertions
// clk, reset, cs, get_data
localparam IDLE         = 4'b0001;
localparam GEN_BLK_ADDR = 4'b0010;
localparam WAITO        = 4'b0100;

// 1. FSM current state must always be one-hot
property p_state_onehot;
  @(posedge clk) disable iff (reset)
    $onehot(cs);
endproperty
assert property (p_state_onehot)
  else $error("FSM current state is NOT one-hot!");

// 2. State transition: IDLE + get_data -> GEN_BLK_ADDR (next cycle) -> WAITO (after 64 cycles)
property p_idle_to_waito;
  @(posedge clk) disable iff (reset)
    (cs == IDLE && $rose(get_data)) |=> 
      (cs == GEN_BLK_ADDR) ##64 (cs == WAITO);
endproperty
assert property (p_idle_to_waito)
  else $error("FSM did not transition correctly: IDLE -> GEN_BLK_ADDR -> WAITO with 64 cycle delay");
