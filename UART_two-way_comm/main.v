`timescale 1ns / 1ps

module uart_2way_communication (
    input wire clk,         // System clock
    input wire reset,       // Reset signal
    input wire rx,          // UART RX input from external device
    input wire tx_start,    // Signal to start transmitting data
    input wire [7:0] tx_data_in, // Data to transmit
    output wire tx,         // UART TX output to external device
    output wire [7:0] rx_data_out, // Received data
    output wire tx_busy,    // Indicates UART TX is busy
    output wire rx_ready    // Indicates RX data is ready
);

    // Internal signals
    wire [7:0] rx_data_internal;
    wire rx_ready_internal;

    // Instantiate UART transmitter module
    uart_tx transmitter (
        .clk(clk),
        .reset_(reset),
        .tx_data(tx_data_in),
        .tx_start_(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Instantiate UART receiver module
    uart_rx receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(rx_data_internal),
        .rx_ready(rx_ready_internal)
    );

    // Assign received data and ready signal to outputs
    assign rx_data_out = rx_data_internal;
    assign rx_ready = rx_ready_internal;

endmodule
