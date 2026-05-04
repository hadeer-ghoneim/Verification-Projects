// module spi_golden_model(
//     input clk,
//     input rst_n,
//     input MOSI,
//     input SS_n,
//     input tx_valid,
//     input [7:0] tx_data,
//     output logic MISO,
//     output logic rx_valid,
//     output logic [9:0] rx_data
// );
    
//     logic [9:0] shift_reg;
//     logic [3:0] bit_count;
//     logic [2:0] command;
//     logic [7:0] tx_shift;
//     logic [3:0] tx_count;
//     logic transmitting;
    
//     enum logic [2:0] {
//         GM_IDLE,
//         GM_CMD,
//         GM_DATA
//     } state;
    
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             state <= GM_IDLE;
//             shift_reg <= '0;
//             bit_count <= '0;
//             rx_valid <= 1'b0;
//             rx_data <= '0;
//             MISO <= 1'b0;
//             tx_shift <= '0;
//             tx_count <= '0;
//             transmitting <= 1'b0;
//             command <= '0;
//         end else begin
//             rx_valid <= 1'b0;
            
//             case (state)
//                 GM_IDLE: begin
//                     bit_count <= '0;
//                     shift_reg <= '0;
//                     if (!SS_n) begin
//                         state <= GM_CMD;
//                     end
//                 end
                
//                 GM_CMD: begin
//                     if (SS_n) begin
//                         state <= GM_IDLE;
//                     end else begin
//                         shift_reg <= {shift_reg[8:0], MOSI};
//                         bit_count <= bit_count + 1;
                        
//                         if (bit_count == 2) begin
//                             command <= shift_reg[1:0];
//                         end
                        
//                         if (bit_count == 10) begin
//                             state <= GM_DATA;
//                             rx_valid <= 1'b1;
//                             rx_data <= shift_reg;
//                             bit_count <= '0;
                            
//                             if (command == 2'b11 && tx_valid) begin
//                                 tx_shift <= tx_data;
//                                 transmitting <= 1'b1;
//                                 tx_count <= '0;
//                             end
//                         end
//                     end
//                 end
                
//                 GM_DATA: begin
//                     if (SS_n) begin
//                         state <= GM_IDLE;
//                         transmitting <= 1'b0;
//                         MISO <= 1'b0;
//                     end else if (transmitting) begin
//                         MISO <= tx_shift[7];
//                         tx_shift <= {tx_shift[6:0], 1'b0};
//                         tx_count <= tx_count + 1;
                        
//                         if (tx_count == 7) begin
//                             transmitting <= 1'b0;
//                             MISO <= 1'b0;
//                         end
//                     end
//                 end
//             endcase
//         end
//     end
    
// endmodule