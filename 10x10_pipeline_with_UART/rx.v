
module uart_rx (
    input wire clk,                // System clock
    input wire reset,              // Reset signal
    input wire rx,                 // UART receive line
    output reg [7:0] rx_data,      // Received data
    output reg rx_ready            // Indicates data is ready to be read
);

    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 100_000_000; // Change according to your FPGA clock frequency
    localparam BIT_TIME = CLOCK_FREQ / BAUD_RATE;

    reg [3:0] rx_state;
    reg [15:0] rx_counter;
    reg [3:0] bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_state <= 0;
            rx_counter <= 0;
            bit_index <= 0;
            rx_ready <= 0;
            rx_data <= 8'b0;
        end else begin
            case (rx_state)
                0: begin // Idle
                    if (rx == 0) begin // Start bit detected
                        rx_state <= 1;
                        rx_counter <= 0;
                    end
                end
                1: begin // Wait for the middle of the start bit
                    if (rx_counter < BIT_TIME / 2) begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_state <= 2; // Read data
                        rx_counter <= 0;
                    end
                end
                2: begin // Read data bits
                    if (rx_counter < BIT_TIME) begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_data[bit_index] <= rx; // Read data bit
                        rx_counter <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            rx_state <= 3; // Stop bit
                            rx_ready <= 1; // Data is ready
                            bit_index <= 0; // Reset for next byte
                        end
                    end
                end
                3: begin // Wait for stop bit
                    if (rx_counter < BIT_TIME) begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_state <= 0; // Go back to idle
                        rx_ready <= 0; // Clear ready flag
                    end
                end
            endcase
        end
    end
endmodule
