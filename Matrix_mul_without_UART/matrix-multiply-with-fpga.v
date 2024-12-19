`timescale 1ns / 1ps

module matrix_mult_fpga #(parameter DATA_WIDTH = 8)(
    input clk,                 // System clock
    input rst,                 // Reset signal
    input start,               // Start signal
    output reg [7:0] LED       // LED output for displaying results
);

    // Clock Divider
    parameter CLOCK_DIVIDER = 75000000;  // Adjust for slower LED updates
    reg clk_div;                         // Divided clock signal
    reg [31:0] counter;                  // Counter for clock division

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:8];
    reg [DATA_WIDTH-1:0] B_matrix [0:8];
    reg [2*DATA_WIDTH-1:0] C_matrix [0:8];

    // Indices and Temporary Variables
    integer i, j, k;  // Loop variables
    reg [2*DATA_WIDTH-1:0] temp_result;

    // Control variables
    reg calc_done;       // Calculation complete flag
    reg [3:0] led_index; // LED index for displaying results sequentially
    reg led_done;        // Flag to stop LED display after final value

    // Clock Divider Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_div <= 0;
        end else if (counter >= CLOCK_DIVIDER) begin
            counter <= 0;
            clk_div <= ~clk_div; // Toggle divided clock
        end else begin
            counter <= counter + 1;
        end
    end

    // Initialize Matrices A and B
    initial begin
        // Matrix A
        A_matrix[0] = 8'd1; A_matrix[1] = 8'd2; A_matrix[2] = 8'd3;
        A_matrix[3] = 8'd4; A_matrix[4] = 8'd5; A_matrix[5] = 8'd6;
        A_matrix[6] = 8'd7; A_matrix[7] = 8'd8; A_matrix[8] = 8'd9;

        // Matrix B
        B_matrix[0] = 8'd9; B_matrix[1] = 8'd8; B_matrix[2] = 8'd7;
        B_matrix[3] = 8'd6; B_matrix[4] = 8'd5; B_matrix[5] = 8'd4;
        B_matrix[6] = 8'd3; B_matrix[7] = 8'd2; B_matrix[8] = 8'd1;
        
        // Initialize result matrix to zero
        for (i = 0; i < 9; i = i + 1) C_matrix[i] = 0;

        calc_done = 0;
        led_index = 0;
        led_done = 0;
    end

    // Matrix Multiplication Logic
    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 9; i = i + 1) C_matrix[i] <= 0;
            calc_done <= 0;
            led_index <= 0;
            led_done <= 0;
            LED <= 8'b00000000; // Turn off LEDs on reset
        end 
        else if (start && !calc_done) begin
            // Perform matrix multiplication
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    temp_result = 0;
                    for (k = 0; k < 3; k = k + 1) begin
                        temp_result = temp_result + A_matrix[i * 3 + k] * B_matrix[k * 3 + j];
                    end
                    C_matrix[i * 3 + j] <= temp_result; // Store result in C
                end
            end
            calc_done <= 1;  // Indicate calculation complete
            led_index <= 0;  // Reset LED index to start displaying results
        end 
        else if (calc_done && !led_done) begin
            // Sequentially display results on LEDs
            LED <= C_matrix[led_index][7:0]; // Display one value at a time
            if (led_index < 8) begin
                led_index <= led_index + 1;
            end 
            else if (led_index == 8) begin
                // Ensure final value at index 8 is displayed for one cycle
                led_done <= 1; // Stop LED display after displaying last value
            end
        end 
        else if (led_done) begin
            LED <= 8'b00000000; // Turn off LEDs after displaying all values
        end
    end
endmodule
