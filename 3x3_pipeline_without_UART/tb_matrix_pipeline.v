`timescale 1ns / 1ps

module tb_matrix_mult_pipelined();

    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg partial_btn;
    reg result_btn;
    wire [7:0] LED;
    
    // Instantiate the matrix multiplication module
    matrix_mult_pipelined uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .partial_btn(partial_btn),
        .result_btn(result_btn),
        .LED(LED)
    );

    // Clock generation (100 MHz)
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        start = 0;
        partial_btn = 0;
        result_btn = 0;
        
        // Apply reset to the design
        rst = 1;
        #10 rst = 0;
        
        // Start the matrix multiplication process
        start = 1;
        #10 start = 0;
        
        // Wait for some cycles to let the computation start
        #100;
        
        // Display partial products
        partial_btn = 1;  // Press the button to display partial products
        #200;             // Wait to let all 27 partial products be displayed
        partial_btn = 0;  // Release the button
        
        // Wait for a moment before displaying results
        #50;

        // Display final results (matrix C)
        result_btn = 1;   // Press the button to display final results
        #100;             // Wait to let all 9 results be displayed
        result_btn = 0;   // Release the button
        
        // End the simulation
        #50;
        $finish;
    end

    // Monitor the LED output for debugging
    initial begin
        $monitor("Time: %0t, LED: %b", $time, LED);
    end

endmodule
