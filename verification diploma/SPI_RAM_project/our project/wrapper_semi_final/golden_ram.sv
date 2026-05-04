module golden_ram #(
    parameter MEM_DEPTH = 256,
    parameter MEM_WIDTH = 8,
    parameter ADDR_SIZE = 8
)(
    input logic [9:0] din,
    input logic rx_valid,
    input logic clk,
    input logic rst_n,
    output logic [7:0] dout,
    output logic tx_valid
);
    // Internal memory and registers
    logic [7:0] mem [0:MEM_DEPTH-1];
    logic [ADDR_SIZE-1:0] address;
    logic [ADDR_SIZE-1:0] data;
    
   

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset outputs and internal registers
            dout <= '0;
            tx_valid <= 1'b0;
            address <= '0;
            data <= '0;
        end
        else begin
            // Default outputs retain previous values
           
            
            if (rx_valid) begin
                case (din[9:8])
                    2'b00: begin  // Set write address
                        address <= din[7:0];
                        tx_valid <= 1'b0;
                    end
                    
                    2'b01: begin  // Write to memory
                        data <= din[7:0];
                        mem[address] <= din[7:0];
                        tx_valid <= 1'b0;
                    end
                    
                    2'b10: begin  // Set read address
                        address <= din[7:0];
                        tx_valid <= 1'b0;
                    end
                    
                    2'b11: begin  // Read from memory
                        dout <= mem[address];
                        tx_valid <= 1'b1;
                    end
                    default: tx_valid <= 1'b0; 
                endcase
            end else begin
                tx_valid <= 1'b0;
            end
        end
    end

    // Function to inspect memory (for verification)
    function logic [7:0] get_memory(input [ADDR_SIZE-1:0] addr);
        return mem[addr];
    endfunction

    // Function to get current read address
    function logic [ADDR_SIZE-1:0] get_read_addr();
        return address;
    endfunction

    // Function to get current write address
    function logic [ADDR_SIZE-1:0] get_write_addr();
        return data;
    endfunction
endmodule