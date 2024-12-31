module matrix_mult_pipelined #(parameter DATA_WIDTH = 4)(
    input clk,                // System clock
    input rst,                // Reset signal
    input rx,                 // UART RX input
    output tx,                // UART TX output
    output reg [7:0] result,  // Output result for matrix C
    output reg [7:0] LED,     // LED output for displaying results
    input [3:0] switch,       // Updated for 10x10
    input [3:0] switch2,
    output reg [7:0] test
);

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:99];  // 10x10 matrix A
    reg [DATA_WIDTH-1:0] B_matrix [0:99];  // 10x10 matrix B
    reg [2*DATA_WIDTH-1:0] C_matrix [0:99]; // Result matrix C
    reg [4:0] rx_count;          // Counter for received data

    // Pipeline Registers for Partial Products and Accumulation
    reg [2*DATA_WIDTH-1:0] partial_product [0:999]; // 100 partial products (for 10x10 matrix multiplication)
    reg [2*DATA_WIDTH-1:0] accum_stage;             // Accumulated sum for each C[i][j]
    reg [6:0] calc_index;                           // Index for calculation of partial products
    reg calc_done;                                  // Flag indicating calculation complete
    reg [6:0] j;                                    // Loop variable for iterating over the calculation steps
    reg write_done;                                 // Flag to check if first cycles are done
    integer i;
    reg [6:0] st = 0;                               // Index for C_matrix writing
    reg [1:0] cc = 0;                               // Counter to track the first cycles
    wire busy;
    
    // UART RX and TX modules for data input/output
    wire [7:0] rx_data;
    wire rx_ready;
    wire rx_valid;
    reg rx_ready_d;  // Delayed version of rx_ready
    reg [4:0] idx;

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
        .tx_busy(busy)             // Not used for this example
    );

    // Always block for receiving data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset matrices and control signals
            for (i = 0; i < 100; i = i + 1) begin
                A_matrix[i] <= 0;
                B_matrix[i] <= 0;
            end
            rx_count <= 0;
            write_done <= 0;
        end else if (rx_ready && rx_count < 200) begin
            if (rx_count < 100) begin
                A_matrix[rx_count] <= rx_data; // Store in Matrix A
            end else begin
                B_matrix[rx_count - 100] <= rx_data; // Store in Matrix B
            end
            rx_count <= rx_count + 1;
        end else if (rx_count >= 200) begin
            write_done <= 1;  // Data has been loaded into A and B matrices
        end
    end

    // Always block for computation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 100; i = i + 1) C_matrix[i] <= 0;
            for (i = 0; i < 1000; i = i + 1) partial_product[i] <= 0;
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
            // Pipeline Logic for 10x10 Matrix multiplication (100 partial products)
            case(j)
                0: begin
                    // Calculating first row of the result
                    for(i = 0; i < 10; i = i + 1) begin
                        partial_product[i] <= A_matrix[i] * B_matrix[i*10];
                    end
                end
                // Continue for other rows...
                // This needs to be expanded for all the 10 rows and columns
            endcase

            // Accumulate partial products for C_matrix
            case (calc_index)
                0: accum_stage <= partial_product[0] + partial_product[1] + partial_product[2]; // C[0][0]
                // Continue for other elements of C_matrix...
            endcase

            // Write to C_matrix after computation
            if (cc >= 2) begin
                C_matrix[st] <= accum_stage;
                calc_index <= calc_index + 1;
                st <= st + 1;  // Increment st after writing to C_matrix
            end

            cc <= cc + 1;
            j <= j + 1;

            if (calc_index >= 100 && idx < 100) begin
                if (!busy) begin
                    calc_done <= 1;
                    result <= C_matrix[idx];
                    idx <= idx + 1;
                end
            end else begin
                calc_done <= 0;
            end
        end
    end

    always @(*) begin
        case (switch)
            4'd0: test = C_matrix[0];    // Least significant byte
            4'd1: test = C_matrix[1];   // Second byte
            // Continue for other elements of C_matrix...
            default: test = C_matrix[0];
        endcase
    end

endmodule
