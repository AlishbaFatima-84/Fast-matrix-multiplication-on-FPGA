module matrix_mult_fpga #(parameter DATA_WIDTH = 4)(  
    input clk,                 // System clock
    input rst,                 // Reset signal
    input rx,                  // UART receive line
	 input [2:0] switch,
	 output reg [7:0] test,
    output tx                  // UART transmit line
);

  

    // UART Signals
    wire [7:0] rx_data;                  // Data received from UART
    wire rx_ready;                       // Data ready signal from UART
    reg [7:0] tx_data;                   // Data to transmit
    reg tx_start;                        // Signal to start UART transmission
    wire tx_busy;                        // UART transmit busy signal

    // Matrices A, B, and Result Matrix C
    reg [DATA_WIDTH-1:0] A_matrix [0:8];  // 4-bit entries for A_matrix
    reg [DATA_WIDTH-1:0] B_matrix [0:8];  // 4-bit entries for B_matrix
    reg [2*DATA_WIDTH-1:0] C_matrix [0:8];  // 8-bit entries for result matrix (2 * DATA_WIDTH)

    // Indices and Temporary Variables
    integer i, j, k;  // Loop variables
    reg [2*DATA_WIDTH-1:0] temp_result;  // 8-bit temp result (since multiplication of 4-bit values may produce 8-bit result)

    // Control Variables
    reg [4:0] rx_count;          // Counter for received data
    reg calc_done;               // Calculation complete flag
    reg [3:0] tx_index;          // Index for transmitting results

    // UART Modules
    uart_rx uart_receiver (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    uart_tx uart_transmitter (
        .clk(clk),
        .reset(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Receive Matrices via UART
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_count <= 0;
        end else if (rx_ready && rx_count < 20) begin
            if (rx_count < 9) begin
                {A_matrix[rx_count+1],A_matrix[rx_count]} <= rx_data; // Store only the lower 4 bits in Matrix A
            end else begin
                {B_matrix[rx_count-10+1],B_matrix[rx_count-10]} <= rx_data; // Store only the lower 4 bits in Matrix B
            end
            rx_count <= rx_count + 2;
        end
    end

    // Matrix Multiplication Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 9; i = i + 1) C_matrix[i] <= 0;
            calc_done <= 0;
        end else if (rx_count == 20 && !calc_done) begin
            // Perform matrix multiplication
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    temp_result = 0;
                    for (k = 0; k < 3; k = k + 1) begin
                        temp_result = temp_result + A_matrix[i * 3 + k] * B_matrix[k * 3 + j];
                    end
                    C_matrix[i * 3 + j] <= temp_result; // Store result in C (8 bits wide)
                end
            end
            calc_done <= 1;  // Indicate calculation complete
        end
    end

    // Transmit Results via UART (Single Driver for tx_index)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 0;
            tx_index <= 0;   // Initialize tx_index here
        end else if (calc_done && tx_index < 9 && !tx_busy) begin
		      tx_start <= 1; 
            tx_data <= C_matrix[tx_index]; // Send lower 8 bits of the result
            tx_index <= tx_index + 1;           // Update tx_index only here
        end else begin
            tx_start <= 0; // Clear start signal
        end  
    end


     always @(*) begin
    case (switch)
       /*3'd0: test = data_buffer[7:0];    // Least significant byte
        3'd1: test = data_buffer[15:8];   // Second byte
        3'd2: test = data_buffer[23:16];  // Third byte
        3'd3: test = data_buffer[31:24];  // Fourth byte
        3'd4: test = data_buffer[39:32];  // Fifth byte
        3'd5: test = data_buffer[47:40];  // Sixth byte
        3'd6: test = data_buffer[55:48];  // Most significant bits (partial byte for 54-bit buffer)
        3'd7: test = data_buffer[63:56];*/
		  3'd0: test = C_matrix[0];    // Least significant byte
        3'd1: test = C_matrix[1];   // Second byte
        3'd2: test = C_matrix[2];  // Third byte
        3'd3: test = C_matrix[3];  // Fourth byte
        3'd4: test = C_matrix[4];  // Fifth byte
        3'd5: test = C_matrix[5];  // Sixth byte
        3'd6: test = C_matrix[6];  // Most significant bits (partial byte for 54-bit buffer)
        3'd7: test = C_matrix[7];

		  default: test = 8'h00;
    endcase
end
endmodule