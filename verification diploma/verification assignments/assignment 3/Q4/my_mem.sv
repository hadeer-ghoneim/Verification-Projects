module my_mem (
  input  logic        clk,
  input  logic        write,
  input  logic        read,
  input  logic [7:0]  data_in,
  input  logic [15:0] address,
  output logic [7:0]  data_out
);

  // Memory Declaration: 9-bit wide, 64K depth
  logic [8:0] mem_array [0:65535];

  always_ff @(posedge clk) begin
    if (write) begin
      // Even parity calculation
      mem_array[address] <= {~^data_in, data_in};
    end
    else if (read) begin
      data_out <= mem_array[address][7:0]; // Output only the 8-bit data
    end
  end

endmodule
