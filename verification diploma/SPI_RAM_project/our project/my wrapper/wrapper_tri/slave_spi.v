module SPI_Slave(
    input clk,
    input rst_n,
    input MOSI_data,
    input SS_n,
    input tx_valid,
    input [7:0] tx_data,
    output reg MISO,
    output reg rx_valid,
    output reg [9:0] rx_data
);
    reg [9:0] parallel_data;
    reg [3:0] counter; //for counting number of bits in serial-to-parallel
    reg [3:0] read_counter;
    reg CHECK_READ; //0 for add, 1 for data;
     (* fsm_encoding = "gray" *) 
    reg [2:0] current;



    reg [2:0] next;

    reg [7:0] tx_shift_reg;
    reg [3:0] tx_bit_cnt;
    reg start_tx;
    
    parameter IDLE= 3'b000;
    parameter CHK_CMD = 3'b001;
    parameter WRITE = 3'b010;
    parameter READ_ADD = 3'b011;
    parameter READ_DATA = 3'b100;

    //state memory
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current <= IDLE;
        end else begin
            current <= next;
        end
    end

    //NEXT STATE LOGIC
    always @(*) begin
        case(current) 
            IDLE:
                if(!SS_n)
                    next = CHK_CMD;
                else
                    next = IDLE;
            
            CHK_CMD:
                if (SS_n)
                    next = IDLE;
                else if(!SS_n && !MOSI_data)
                    next = WRITE; 
                else if(!SS_n && MOSI_data) begin
                    if(!CHECK_READ)     
                        next = READ_ADD;
                    else 
                        next = READ_DATA;               
                end

            WRITE:
                if(SS_n)
                    next = IDLE;
                else begin
                    next = WRITE;
                end
            
            READ_ADD:
                if (SS_n) begin
                    next = IDLE; 
                end else if (!SS_n /* add condition to check read*/ ) begin
                    next = READ_ADD; 
                end

            READ_DATA:
                if (SS_n) begin
                    next = IDLE; 
                end else if (!SS_n /* add condition to check read*/ ) begin
                    next = READ_DATA;   
                end
        endcase        
    end

    //OUTPUT
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_valid      <= 0;
            MISO          <= 0;
            rx_data       <= 0;
            counter       <= 0;
            tx_shift_reg  <= 8'b0;
            tx_bit_cnt    <= 0;
            start_tx      <= 0;
            CHECK_READ    <= 0;
            parallel_data <= 0;
            //read_counter  <= 0;
        end else begin
            case(current) 
                IDLE: begin
                    rx_valid      <= 0;
                    rx_data       <= 0;
                    counter       <= 0;
                    tx_bit_cnt    <= 0;
                    start_tx      <= 0;
                    //CHECK_READ    <= 0;
                    parallel_data <= 0;
                    //read_counter  <= 0;
                end 

                CHK_CMD: begin
                    //counter <= 0;
                end

                WRITE: begin
                    parallel_data <= {parallel_data[8:0], MOSI_data};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data <= parallel_data;
                        counter <= 0;
                        //SS_n = 1'b1; //was hashed
                    end else begin
                        rx_valid <= 1'b0;
                    end
                end 

                READ_ADD: begin 
                    //parallel_data <= tx_data;                    
                    parallel_data <= {parallel_data[8:0], MOSI_data};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data <= parallel_data;
                        counter <= 0;
                        CHECK_READ <= 1;
                        //SS_n = 1'b1; //was hashed
                    end else begin
                        rx_valid <= 1'b0;
                    end
                end

                READ_DATA: begin
                    //first we need to get parallel data as usual for read data command (full 10 clk cycles per usual)
                    parallel_data <= {parallel_data[8:0], MOSI_data};
                    counter <= counter + 1;
                    if (counter == 10) begin
                        rx_valid <= 1'b1;
                        rx_data  <= parallel_data;
                        counter  <= 0;
                    end else begin
                        rx_valid <= 1'b0;
                    end
                
                    if (tx_valid) begin
                        tx_shift_reg <= tx_data;
                        start_tx     <= 1;
                    end
                
                    if (start_tx) begin
                        MISO <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0}; // Shift left
                        tx_bit_cnt <= tx_bit_cnt + 1;

                        if (tx_bit_cnt == 7) begin
                            tx_bit_cnt <= 0;
                            start_tx   <= 0;
                            CHECK_READ <= 0;
                        end
                    end
                end

                default: rx_valid <= 1'b0;

            endcase
        end
    end

endmodule