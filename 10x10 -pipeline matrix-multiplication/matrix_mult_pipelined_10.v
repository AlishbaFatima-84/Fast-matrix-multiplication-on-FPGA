
module matrix_mult_pipelined_10 #(parameter DATA_WIDTH = 8)(
    input clk,                // System clock
    input rst,                // Reset signal
    input start,              // Start signal
    output reg [7:0] LED      // LED output for displaying results
);

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:99];
    reg [DATA_WIDTH-1:0] B_matrix [0:99];
    reg [2*DATA_WIDTH-1:0] C_matrix [0:99];  // Result matrix

    // Pipeline Registers for Partial Products and Accumulation
    reg [2*DATA_WIDTH-1:0] partial_product [0:9]; // 10 partial products per stage
    reg [2*DATA_WIDTH-1:0] accum_stage;          // Accumulated sum for each C[i][j]
    reg [6:0] calc_index;                        // C matrix index for calculation
    reg [6:0] led_index;                         // Index for displaying results
    reg calc_done;                               // Flag indicating calculation complete
    reg led_done;                                // LED completion flag
    reg [6:0] st = 0;                            // Index for C_matrix writing
    reg [6:0] j;                                 // Loop variable for iterating over the calculation steps
    reg [1:0] cc = 0;                            // Counter to track the first two cycles
    reg write_done;                              // Flag to check if first two cycles are done
    integer i;

    // Clock Divider Logic: Divide the clock by a value for slower LED updates
    parameter CLOCK_DIVIDER = 75000000;  // Adjust for slower LED updates
    reg clk_div;                         // Divided clock signal
    reg [31:0] counter;                  // Counter for clock division

    // Clock divider logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 32'd0;  // Reset the counter
            clk_div <= 0;      // Reset the divided clock signal
        end else begin
            if (counter >= CLOCK_DIVIDER - 1) begin
                counter <= 32'd0;  // Reset counter when it reaches the division value
                clk_div <= ~clk_div; // Toggle the clock division signal
            end else begin
                counter <= counter + 1;  // Increment the counter
            end
        end
    end
    // Initialize Matrices A and B
	initial begin
		 // Initialize Matrix A (10x10)
		 for (i = 0; i < 100; i = i + 1) begin
			  A_matrix[i] = (i % 3) + 1;  // Repeat 1, 2, 3 across rows
		 end

		 // Initialize Matrix B (10x10)
		 for (i = 0; i < 100; i = i + 1) begin
			  B_matrix[i] = 3 - (i % 3);  // Repeat 3, 2, 1 across rows
		 end

		 // Initialize Control Signals
		 calc_done = 0;
		 led_index = 0;
		 led_done = 0;

		 // Initialize Result Matrix and Control Registers
		 for (i = 0; i < 100; i = i + 1) C_matrix[i] = 0;
		 accum_stage = 0;
		 for (i = 0; i < 10; i = i + 1) partial_product[i] = 0;
		 write_done = 0;  // Set the flag to false initially
	end


    // Pipelined Matrix Multiplication Logic
    always @(posedge clk_div or posedge rst) begin
        if (rst) begin
            // Reset all signals and matrices
            for (i = 0; i < 100; i = i + 1) C_matrix[i] <= 0;
            accum_stage <= 0;
            for (i = 0; i < 10; i = i + 1) partial_product[i] <= 0;

            calc_done <= 0;
            led_index <= 0;
            led_done <= 0;
            LED <= 8'b00000000;
            calc_index <= 0;
            j <= 0; // Initialize new variable j
            write_done <= 0; // Reset the flag
        end
        else if (start && !calc_done) begin
            // Perform the pipelined computation
            if (calc_index < 100) begin
                // Use the loop variable `j` to control the calculation of partial products
                case(j)

                    0: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+0];

                    end

                    1: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+1];

                    end

                    2: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+2];

                    end

                    3: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+3];

                    end

                    4: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+4];

                    end

                    5: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+5];

                    end

                    6: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+6];

                    end

                    7: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+7];

                    end

                    8: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+8];

                    end

                    9: begin
                        partial_product[0] <= A_matrix[0*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[0*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[0*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[0*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[0*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[0*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[0*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[0*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[0*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[0*10+9] * B_matrix[9*10+9];

                    end

                    10: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+0];

                    end

                    11: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+1];

                    end

                    12: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+2];

                    end

                    13: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+3];

                    end

                    14: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+4];

                    end

                    15: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+5];

                    end

                    16: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+6];

                    end

                    17: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+7];

                    end

                    18: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+8];

                    end

                    19: begin
                        partial_product[0] <= A_matrix[1*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[1*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[1*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[1*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[1*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[1*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[1*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[1*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[1*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[1*10+9] * B_matrix[9*10+9];

                    end

                    20: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+0];

                    end

                    21: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+1];

                    end

                    22: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+2];

                    end

                    23: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+3];

                    end

                    24: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+4];

                    end

                    25: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+5];

                    end

                    26: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+6];

                    end

                    27: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+7];

                    end

                    28: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+8];

                    end

                    29: begin
                        partial_product[0] <= A_matrix[2*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[2*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[2*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[2*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[2*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[2*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[2*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[2*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[2*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[2*10+9] * B_matrix[9*10+9];

                    end

                    30: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+0];

                    end

                    31: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+1];

                    end

                    32: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+2];

                    end

                    33: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+3];

                    end

                    34: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+4];

                    end

                    35: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+5];

                    end

                    36: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+6];

                    end

                    37: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+7];

                    end

                    38: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+8];

                    end

                    39: begin
                        partial_product[0] <= A_matrix[3*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[3*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[3*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[3*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[3*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[3*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[3*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[3*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[3*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[3*10+9] * B_matrix[9*10+9];

                    end

                    40: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+0];

                    end

                    41: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+1];

                    end

                    42: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+2];

                    end

                    43: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+3];

                    end

                    44: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+4];

                    end

                    45: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+5];

                    end

                    46: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+6];

                    end

                    47: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+7];

                    end

                    48: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+8];

                    end

                    49: begin
                        partial_product[0] <= A_matrix[4*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[4*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[4*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[4*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[4*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[4*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[4*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[4*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[4*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[4*10+9] * B_matrix[9*10+9];

                    end

                    50: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+0];

                    end

                    51: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+1];

                    end

                    52: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+2];

                    end

                    53: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+3];

                    end

                    54: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+4];

                    end

                    55: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+5];

                    end

                    56: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+6];

                    end

                    57: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+7];

                    end

                    58: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+8];

                    end

                    59: begin
                        partial_product[0] <= A_matrix[5*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[5*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[5*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[5*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[5*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[5*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[5*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[5*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[5*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[5*10+9] * B_matrix[9*10+9];

                    end

                    60: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+0];

                    end

                    61: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+1];

                    end

                    62: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+2];

                    end

                    63: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+3];

                    end

                    64: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+4];

                    end

                    65: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+5];

                    end

                    66: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+6];

                    end

                    67: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+7];

                    end

                    68: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+8];

                    end

                    69: begin
                        partial_product[0] <= A_matrix[6*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[6*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[6*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[6*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[6*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[6*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[6*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[6*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[6*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[6*10+9] * B_matrix[9*10+9];

                    end

                    70: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+0];

                    end

                    71: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+1];

                    end

                    72: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+2];

                    end

                    73: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+3];

                    end

                    74: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+4];

                    end

                    75: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+5];

                    end

                    76: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+6];

                    end

                    77: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+7];

                    end

                    78: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+8];

                    end

                    79: begin
                        partial_product[0] <= A_matrix[7*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[7*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[7*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[7*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[7*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[7*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[7*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[7*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[7*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[7*10+9] * B_matrix[9*10+9];

                    end

                    80: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+0];

                    end

                    81: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+1];

                    end

                    82: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+2];

                    end

                    83: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+3];

                    end

                    84: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+4];

                    end

                    85: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+5];

                    end

                    86: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+6];

                    end

                    87: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+7];

                    end

                    88: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+8];

                    end

                    89: begin
                        partial_product[0] <= A_matrix[8*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[8*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[8*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[8*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[8*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[8*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[8*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[8*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[8*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[8*10+9] * B_matrix[9*10+9];

                    end

                    90: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+0];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+0];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+0];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+0];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+0];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+0];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+0];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+0];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+0];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+0];

                    end

                    91: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+1];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+1];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+1];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+1];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+1];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+1];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+1];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+1];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+1];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+1];

                    end

                    92: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+2];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+2];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+2];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+2];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+2];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+2];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+2];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+2];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+2];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+2];

                    end

                    93: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+3];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+3];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+3];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+3];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+3];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+3];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+3];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+3];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+3];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+3];

                    end

                    94: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+4];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+4];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+4];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+4];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+4];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+4];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+4];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+4];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+4];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+4];

                    end

                    95: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+5];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+5];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+5];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+5];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+5];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+5];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+5];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+5];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+5];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+5];

                    end

                    96: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+6];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+6];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+6];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+6];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+6];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+6];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+6];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+6];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+6];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+6];

                    end

                    97: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+7];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+7];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+7];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+7];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+7];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+7];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+7];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+7];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+7];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+7];

                    end

                    98: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+8];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+8];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+8];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+8];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+8];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+8];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+8];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+8];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+8];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+8];

                    end

                    99: begin
                        partial_product[0] <= A_matrix[9*10+0] * B_matrix[0*10+9];
                        partial_product[1] <= A_matrix[9*10+1] * B_matrix[1*10+9];
                        partial_product[2] <= A_matrix[9*10+2] * B_matrix[2*10+9];
                        partial_product[3] <= A_matrix[9*10+3] * B_matrix[3*10+9];
                        partial_product[4] <= A_matrix[9*10+4] * B_matrix[4*10+9];
                        partial_product[5] <= A_matrix[9*10+5] * B_matrix[5*10+9];
                        partial_product[6] <= A_matrix[9*10+6] * B_matrix[6*10+9];
                        partial_product[7] <= A_matrix[9*10+7] * B_matrix[7*10+9];
                        partial_product[8] <= A_matrix[9*10+8] * B_matrix[8*10+9];
                        partial_product[9] <= A_matrix[9*10+9] * B_matrix[9*10+9];

                    end

                endcase

                // Stage 2: Accumulate partial products (accumulate result)
                accum_stage <= partial_product[0] + partial_product[1] + partial_product[2] +
                               partial_product[3] + partial_product[4] + partial_product[5] +
                               partial_product[6] + partial_product[7] + partial_product[8] +
                               partial_product[9];

                // Write to C_matrix starting from the third cycle (when cc >= 2)
                if (cc >= 2 || write_done) begin
                    C_matrix[st] <= accum_stage;
						  LED  <= accum_stage;
                    calc_index <= calc_index + 1;
                    st <= st + 1;  // Increment st after writing to C_matrix
                    write_done <= 1; // After the first two cycles, keep writing
                end

                // Increment the clock cycle counter
                cc <= cc + 1;

                // Update calc_index and j to go to the next position
                j <= j + 1; // Increment j to the next step
            end

            // If all elements are processed, mark as done
            if (calc_index >= 100) begin
                calc_done <= 1;
            end
        end
        else if (calc_done && !led_done) begin
            // Sequentially display results on LEDs
            LED <= C_matrix[led_index][7:0]; // Display the 8-bit result on the LED
            if (led_index < 99) begin
                led_index <= led_index + 1;
            end else begin
                led_done <= 1;  // Stop after displaying all values
                LED <= 8'b00000000;
            end
        end
    end
endmodule
