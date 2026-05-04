// Arbiter SVA
// clk, reset, request, grant, frame, irdy

// 1. Grant timing after request
property p_request_to_grant;
  @(posedge clk) disable iff (reset)
    $rose(request) |-> ##[2:5] grant;
endproperty
assert property (p_request_to_grant)
  else $error("Grant was not asserted within 2 to 5 cycles after request rising edge");

// 2. Master acknowledges by lowering frame and irdy
property p_grant_acknowledge;
  @(posedge clk) disable iff (reset)
    $rose(grant) |-> ($past(frame) && $past(irdy) && !frame && !irdy);
endproperty
assert property (p_grant_acknowledge)
  else $error("Master did not acknowledge grant correctly by lowering frame and irdy");

// 3. Grant deassertion after transaction complete
property p_transaction_complete;
  @(posedge clk) disable iff (reset)
    ($rose(frame) && $rose(irdy) && grant) |=> ##1 !grant;
endproperty
assert property (p_transaction_complete)
  else $error("Grant was not lowered 1 cycle after transaction completion");
