module packet_example;

  // 1. Define a user-defined 7-bit type
  typedef logic [6:0] seven_bit_t;

  // 2. Define a typedef struct for the packet fields
  typedef struct packed {
    seven_bit_t crc;     // Bits [0:6]
    seven_bit_t data;    // Bits [7:13]
    seven_bit_t cmd;     // Bits [14:20]
    seven_bit_t header;  // Bits [21:27]
  } packet;

  // 3. Declare a structure variable of type packet
  packet my_packet;

  initial begin
    // Assign the header field to 7'h5A
    my_packet.header = 7'h5A;

    // Assign example values to other fields
    my_packet.cmd   = 7'h12;
    my_packet.data  = 7'h34;
    my_packet.crc   = 7'h7F;

    // Display the packet contents
    $display("Packet Contents:");
    $display("Header = %h", my_packet.header);
    $display("Cmd    = %h", my_packet.cmd);
    $display("Data   = %h", my_packet.data);
    $display("CRC    = %h", my_packet.crc);

    // Display the entire 28-bit packed value
    $display("Full Packet (28-bit) = %h", my_packet);
  end
endmodule
