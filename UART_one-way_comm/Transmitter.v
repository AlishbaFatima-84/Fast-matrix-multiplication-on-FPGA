`timescale 1ns / 1ps
module uart_tx (
    input wire clk,                // System clock
    input wire reset_,              // Reset signal
    input wire [7:0] tx_data,      // Data to send
    input wire tx_start_,           // Start sending data
    output reg tx,                 // UART transmit line
    output reg tx_busy,             // Indicates UART is busy sending data
	 output reg [7:0] data
);

always @ (*) begin
	data = tx_data;
end

    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 100_000_000; // Change according to your FPGA clock frequency
    localparam BIT_TIME = CLOCK_FREQ / BAUD_RATE;

Button uut (
	.clk(clk),
	.in(reset_),
	.out(reset)
	);
	
Button uut2 (
	.clk(clk),
	.in(tx_start_),
	.out(tx_start)
	);
    reg [3:0] tx_state;
    reg [7:0] tx_buffer;
    reg [15:0] tx_counter;
    reg [3:0] bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_state <= 0;
            tx_busy <= 0;
            tx_counter <= 0;
            tx <= 1; // Idle state
        end else begin
            case (tx_state)
                0: begin // Idle
                    if (tx_start && !tx_busy) begin
                        tx_buffer <= tx_data;
                        tx_state <= 1; // Start bit
                        tx_busy <= 1;
                    end
                end
                1: begin // Start bit
                    if (tx_counter < BIT_TIME) begin
                        tx_counter <= tx_counter + 1;
                    end else begin
                        tx <= 0; // Transmit start bit
                        tx_counter <= 0;
                        tx_state <= 2; // Transmit data
                        bit_index <= 0;
                    end
                end
                2: begin // Transmit data bits
                    if (tx_counter < BIT_TIME) begin
                        tx_counter <= tx_counter + 1;
                    end else begin
                        tx <= tx_buffer[bit_index]; // Send data bit
                        tx_counter <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            tx_state <= 3; // Stop bit
                        end
                    end
                end
                3: begin // Stop bit
                    if (tx_counter < BIT_TIME) begin
                        tx_counter <= tx_counter + 1;
                    end else begin
                        tx <= 1; // Idle state
                        tx_state <= 0; // Go back to idle
                        tx_busy <= 0; // Not busy anymore
                    end
                end
            endcase
        end
    end
endmodule
