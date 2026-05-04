module SinglePort_SRAM #(
    parameter MEM_WIDTH = 8,
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input clk,
    input rst_n,
    input rx_valid,           // Data on din is valid when high
    input [9:0] din,          // Operation + data
    output reg [7:0] dout,    // Output data
    output reg tx_valid       // High when dout is valid
);

    reg [MEM_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    reg [ADDR_SIZE-1:0] address;
    reg [MEM_WIDTH-1:0] data;

    always @(posedge clk) begin
        if (!rst_n) begin
            dout     <= 8'b0;
            tx_valid <= 1'b0;
            address  <= {ADDR_SIZE{1'b0}};
            data     <= {MEM_WIDTH{1'b0}};
        end else begin
            if (rx_valid) begin
                case (din[9:8])
                    2'b00: begin
                        address <= din[7:0]; // Set address
                        tx_valid <=1'b0;
                    end
                    2'b01: begin
                        data <= din[7:0];
                        mem[address] <= din[7:0]; // Write to memory
                        tx_valid <=1'b0;
                    end
                    2'b10: begin
                        address <= din[7:0]; // Set address for reading
                        tx_valid <=1'b0;
                    end
                    2'b11: begin
                        dout <= mem[address]; // Read from memory
                        tx_valid <= 1'b1;
                    end
                    default: tx_valid <= 1'b0; 
                endcase
            end else begin
                tx_valid <= 1'b0;
            end
        end
    end
endmodule

