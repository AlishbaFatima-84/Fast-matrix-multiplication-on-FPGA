module tb_matrix_mult_pipelined;

    // Parameters
    parameter DATA_WIDTH = 8;

    // Inputs
    reg clk;
    reg rst;
    reg start;

    // Outputs
    wire [7:0] LED;

    // Instantiate the module under test (MUT)
    matrix_mult_pipelined #(DATA_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .LED(LED)
    );

    // Clock generation (50 MHz clock)
    always begin
        #5 clk = ~clk;  // Toggle clock every 5ns, creating a 10ns period (50MHz)
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        start = 0;

        // Reset the design
        rst = 1;       // Apply reset
        #20;           // Wait for 20ns (2 clock cycles)
        rst = 0;       // Deassert reset

        // Start the multiplication process
        #10;
        start = 1;     // Start the matrix multiplication
       
       
    end

    // Monitor the LED output during simulation
    initial begin
        $monitor("At time %t, LED = %h", $time, LED);
    end
endmodule
