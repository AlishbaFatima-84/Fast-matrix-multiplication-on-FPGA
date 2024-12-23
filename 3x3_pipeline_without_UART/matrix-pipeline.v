module matrix_mult_pipelined #(parameter DATA_WIDTH = 8)(
    input clk,                // System clock
    input rst,                // Reset signal
    input start,              // Start signal
    input partial_btn,        // Partial button for displaying partial products
    input result_btn,         // Result button for displaying final matrix C
    output reg [7:0] LED      // LED output for displaying results
);

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:8];  // 3x3 matrix A
    reg [DATA_WIDTH-1:0] B_matrix [0:8];  // 3x3 matrix B
    reg [2*DATA_WIDTH-1:0] C_matrix [0:8];  // Result matrix C

    // Pipeline Registers for Partial Products and Accumulation
    reg [2*DATA_WIDTH-1:0] partial_product [0:26]; // 27 partial products (for 3x3 matrix multiplication)
    reg [2*DATA_WIDTH-1:0] accum_stage;           // Accumulated sum for each C[i][j]
    reg [4:0] calc_index;                         // Index for calculation of partial products
    reg [4:0] led_index;                          // Index for displaying results
    reg calc_done;                                // Flag indicating calculation complete
	 reg [4:0] partial_led_index;                  // Index for displaying partial products
    reg [3:0] result_led_index;                   // Index for displaying results
    reg led_done;                                 // Flag to stop LED updates after showing all partial products
    reg [3:0] st = 0;                             // Index for C_matrix writing
    reg [1:0] cc = 0;                             // Counter to track the first two cycles
	 reg [3:0] j;                                  // Loop variable for iterating over the calculation steps
    reg write_done;                               // Flag to check if first two cycles are done
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
        // Matrix A (3x3)
        A_matrix[0] = 8'd1; A_matrix[1] = 8'd2; A_matrix[2] = 8'd3;
        A_matrix[3] = 8'd4; A_matrix[4] = 8'd5; A_matrix[5] = 8'd6;
        A_matrix[6] = 8'd7; A_matrix[7] = 8'd8; A_matrix[8] = 8'd9;

        // Matrix B (3x3)
        B_matrix[0] = 8'd9; B_matrix[1] = 8'd8; B_matrix[2] = 8'd7;
        B_matrix[3] = 8'd6; B_matrix[4] = 8'd5; B_matrix[5] = 8'd4;
        B_matrix[6] = 8'd3; B_matrix[7] = 8'd2; B_matrix[8] = 8'd1;

        // Initialize Control Signals
        calc_done = 0;
        partial_led_index = 0;
        result_led_index = 0;
        led_done = 0;

        // Initialize Matrices and Control Registers
        for (i = 0; i < 9; i = i + 1) C_matrix[i] = 0;
        accum_stage = 0;
        for (i = 0; i < 27; i = i + 1) partial_product[i] = 0;
        write_done = 0;  // Set the flag to false initially
    end

     // Pipelined Matrix Multiplication Logic
	always @(posedge clk_div or posedge rst) begin
		 if (rst) begin
			  // Reset all signals and matrices
			  for (i = 0; i < 9; i = i + 1) C_matrix[i] <= 0;
			  accum_stage <= 0;
			  for (i = 0; i < 27; i = i + 1) partial_product[i] <= 0;

			  calc_done <= 0;
			  led_index <= 0;
			  led_done <= 0;
			  LED <= 8'b00000000;
			  calc_index <= 0;
			  write_done <= 0; // Reset the flag
			  j <= 0; // Initialize new variable j
		 end
		 else if (start && !calc_done) begin
			  // Perform the pipelined computation for all partial products
			  case(j)
					0: begin
						 partial_product[0] <= A_matrix[0] * B_matrix[0];
						 partial_product[1] <= A_matrix[1] * B_matrix[3];
						 partial_product[2] <= A_matrix[2] * B_matrix[6];
					end
					1: begin
						 partial_product[3] <= A_matrix[0] * B_matrix[1];
						 partial_product[4] <= A_matrix[1] * B_matrix[4];
						 partial_product[5] <= A_matrix[2] * B_matrix[7];
					end
					2: begin
						 partial_product[6] <= A_matrix[0] * B_matrix[2];
						 partial_product[7] <= A_matrix[1] * B_matrix[5];
						 partial_product[8] <= A_matrix[2] * B_matrix[8];
					end
					3: begin
						 partial_product[9] <= A_matrix[3] * B_matrix[0];
						 partial_product[10] <= A_matrix[4] * B_matrix[3];
						 partial_product[11] <= A_matrix[5] * B_matrix[6];
					end
					4: begin
						 partial_product[12] <= A_matrix[3] * B_matrix[1];
						 partial_product[13] <= A_matrix[4] * B_matrix[4];
						 partial_product[14] <= A_matrix[5] * B_matrix[7];
					end
					5: begin
						 partial_product[15] <= A_matrix[3] * B_matrix[2];
						 partial_product[16] <= A_matrix[4] * B_matrix[5];
						 partial_product[17] <= A_matrix[5] * B_matrix[8];
					end
					6: begin
						 partial_product[18] <= A_matrix[6] * B_matrix[0];
						 partial_product[19] <= A_matrix[7] * B_matrix[3];
						 partial_product[20] <= A_matrix[8] * B_matrix[6];
					end
					7: begin
						 partial_product[21] <= A_matrix[6] * B_matrix[1];
						 partial_product[22] <= A_matrix[7] * B_matrix[4];
						 partial_product[23] <= A_matrix[8] * B_matrix[7];
					end
					8: begin
						 partial_product[24] <= A_matrix[6] * B_matrix[2];
						 partial_product[25] <= A_matrix[7] * B_matrix[5];
						 partial_product[26] <= A_matrix[8] * B_matrix[8];
					end
			  endcase

			  // Stage 2: Accumulate partial products (accumulate result for each C[i][j])
			  case (calc_index)
					0: accum_stage <= partial_product[0] + partial_product[1] + partial_product[2]; // C[0][0]
					1: accum_stage <= partial_product[3] + partial_product[4] + partial_product[5]; // C[0][1]
					2: accum_stage <= partial_product[6] + partial_product[7] + partial_product[8]; // C[0][2]
					3: accum_stage <= partial_product[9] + partial_product[10] + partial_product[11]; // C[1][0]
					4: accum_stage <= partial_product[12] + partial_product[13] + partial_product[14]; // C[1][1]
					5: accum_stage <= partial_product[15] + partial_product[16] + partial_product[17]; // C[1][2]
					6: accum_stage <= partial_product[18] + partial_product[19] + partial_product[20]; // C[2][0]
					7: accum_stage <= partial_product[21] + partial_product[22] + partial_product[23]; // C[2][1]
					8: accum_stage <= partial_product[24] + partial_product[25] + partial_product[26]; // C[2][2]
			  endcase

			  // Write to C_matrix starting from the third cycle (when cc >= 2)
			  if (cc >= 2 || write_done) begin
					C_matrix[st] <= accum_stage;
					calc_index <= calc_index + 1;
					st <= st + 1;  // Increment st after writing to C_matrix
					write_done <= 1; // After the first two cycles, keep writing
			  end

			  // Increment the clock cycle counter
			  cc <= cc + 1;
			  // Update calc_index and j to go to the next position
			  j <= j + 1; // Increment j to the next step

			  // If all elements are processed, mark as done
			  if (calc_index >= 9) begin
					calc_done <= 1;
			  end
		 end
		 else if (partial_btn && !led_done) begin
			  // Display all 27 partial products sequentially
			  LED <= partial_product[partial_led_index][7:0];  
			  if (partial_led_index < 27) begin
					partial_led_index <= partial_led_index + 1;
			  end else begin
					led_done <= 1;
					LED <= 8'b00000000;
					partial_led_index <= 0;
			  end
		 end
		 else if (result_btn && calc_done) begin
			  // Display final result from C_matrix
			  if (result_led_index < 9) begin
					LED <= C_matrix[result_led_index][7:0];  // Display 8 bits of the result from C_matrix
					result_led_index <= result_led_index + 1;
			  end else begin
					led_done <= 1;  // Stop after displaying all values
					LED <= 8'b00000000;
					result_led_index <= 0;  // Reset for future displays
			  end
		 end
	end

endmodule
