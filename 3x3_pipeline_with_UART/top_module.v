module matrix_mult_pipelined #(parameter DATA_WIDTH = 4)(
    input clk,               // System clock
    input rst,               // Reset signal
    input rx,                // UART RX input
    output tx,               // UART TX output
    output reg [7:0] result, // Output result for matrix C
    output reg [7:0] LED,    // LED output for displaying results
    input [2:0] switch,
    input [2:0] switch2,
    output reg [7:0] test
);

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:8];  // 3x3 matrix A
    reg [DATA_WIDTH-1:0] B_matrix [0:8];  // 3x3 matrix B
    reg [2*DATA_WIDTH-1:0] C_matrix [0:8]; // Result matrix C
    reg [4:0] rx_count;          // Counter for received data

    // Pipeline Registers for Partial Products and Accumulation
    reg [2*DATA_WIDTH-1:0] partial_product [0:26]; // 27 partial products (for 3x3 matrix multiplication)
    reg [2*DATA_WIDTH-1:0] accum_stage;            // Accumulated sum for each C[i][j]
    reg [4:0] calc_index;                          // Index for calculation of partial products
    reg calc_done;                                 // Flag indicating calculation complete
    reg [3:0] j;                                   // Loop variable for iterating over the calculation steps
    reg write_done;                                // Flag to check if first two cycles are done
    integer i;
    reg [3:0] st = 0;                              // Index for C_matrix writing
    reg [1:0] cc = 0;                              // Counter to track the first two cycles
wire busy;
    // UART RX and TX modules for data input/output
    wire [7:0] rx_data;
    wire rx_ready;
    wire rx_valid;
    reg rx_ready_d;  // Delayed version of rx_ready
    reg [3:0] idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_ready_d <= 0;
        end else begin
            rx_ready_d <= rx_valid;
        end
    end

    wire rx_valid_edge = rx_valid && !rx_ready_d;  // Detect rising edge of rx_ready

    uart_rx #(
        .CLOCK_FREQ(100_000_000),  // FPGA clock frequency
        .BAUD_RATE(9600)           // Baud rate for UART
    ) uart_rx_inst (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    uart_tx #(
        .CLOCK_FREQ(100_000_000),  // FPGA clock frequency
        .BAUD_RATE(9600)           // Baud rate for UART
    ) uart_tx_inst (
        .clk(clk),
        .reset(rst),
        .tx_data(result),
        .tx_start(calc_done),
        .tx(tx),                   // Transmit line
        .tx_busy(busy)                 // Not used for this example
    );

    // Always block for receiving data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset matrices and control signals
            for (i = 0; i < 9; i = i + 1) begin
                A_matrix[i] <= 0;
                B_matrix[i] <= 0;
            end
            rx_count <= 0;
            write_done <= 0;
        end else if (rx_ready && rx_count < 20) begin
            if (rx_count < 9) begin
                A_matrix[rx_count] <= rx_data; // Store in Matrix A
            end else begin
                B_matrix[rx_count - 9] <= rx_data; // Store in Matrix B
            end
            rx_count <= rx_count + 1;
        end else if (rx_count >= 20) begin
            write_done <= 1;  // Data has been loaded into A and B matrices
        end
    end

    // Always block for computation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 9; i = i + 1) C_matrix[i] <= 0;
            for (i = 0; i < 27; i = i + 1) partial_product[i] <= 0;
            accum_stage <= 0;
            LED <= 8'b00000000;
            result <= 8'b00000000;
            calc_done <= 0;
            calc_index <= 0;
            j <= 0;
            st <= 0;
            cc <= 0;
				idx <= 0;
        end else if (write_done && !calc_done) begin
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
					 
            // Accumulate partial products for C_matrix
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
            if (cc >= 2) begin
                C_matrix[st] <= accum_stage;
					
               // result <= C_matrix[st];
                calc_index <= calc_index + 1;
                st <= st + 1;  // Increment st after writing to C_matrix
            end

            // Increment the clock cycle counter
            cc <= cc + 1;
            // Update calc_index and j to go to the next position
            j <= j + 1; // Increment j to the next step

            // If all elements are processed, mark as done
            if (calc_index >= 9 && idx<9) begin
				if (!busy) begin
                calc_done <= 1;
					 result <= C_matrix[idx];
					 idx <= idx+1;
					 end
					 
            end
				else calc_done <= 0;
        end
    end

    always @(*) begin
        case (switch)
            3'd0: test = C_matrix[0];    // Least significant byte
            3'd1: test = C_matrix[1];   // Second byte
            3'd2: test = C_matrix[2];   // Third byte
            3'd3: test = C_matrix[3];   // Fourth byte
            3'd4: test = C_matrix[4];   // Fifth byte
            3'd5: test = C_matrix[5];   // Sixth byte
            3'd6: test = C_matrix[6];   // Most significant bits
            3'd7: test = C_matrix[7];
            default: test = C_matrix[0];
        endcase
    end

endmodule