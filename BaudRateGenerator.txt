module baud_rate_generator (
    input wire sys_clk,           // System clock
    input wire rst,               // Reset signal
    input wire [1:0] sel_baud,    // Baud rate select (2 bits for 4 possible rates)
    output reg tx_baud_clk,       // Baud clock for transmitter
    output reg rx_baud_clk        // Baud clock for receiver
);
    
    reg [15:0] counter_rx;
    reg [2:0] counter_tx;
    reg [15:0] baud_limit;
    reg [4:0] q1;
    reg [4:0] q2;

    // Baud rate selection logic
    always @(*) begin
        case(sel_baud)
            2'b00: baud_limit = (100_000_000 / (8 * 4800));   // 4800 baud
            2'b01: baud_limit = (100_000_000 / (8 * 9600));   // 9600 baud
            2'b10: baud_limit = (100_000_000 / (8 * 19200));  // 19200 baud
            2'b11: baud_limit = (100_000_000 / (8 * 57600));  // 57600 baud
            default: baud_limit = (100_000_000 / (8 * 9600)); // Default to 9600 baud
        endcase
    end

    // Generate the baud clock for Receiver (rx_baud_clk)
    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            counter_rx <= 0;
            rx_baud_clk <= 0; // Reset RX baud clock
        end else begin
            if (counter_rx >= ((baud_limit / 2)-1)) begin // Adjust to match baud_limit
                counter_rx <= 0;
                rx_baud_clk <= ~rx_baud_clk; // Toggle RX baud clock
            end else begin
                counter_rx <= counter_rx + 1; // Increment counter_rx
            end
        end
    end
    
    // Generate the baud clock for Transmitter (tx_baud_clk)
    always @(posedge rx_baud_clk or posedge rst) begin
        if (rst) begin
            counter_tx <= 0;
            tx_baud_clk <= 0; // Reset TX baud clock
        end else begin
            if (counter_tx == 3) begin // Generate 8x the baud clock for TX
                counter_tx <= 0;
                tx_baud_clk <= ~tx_baud_clk; // Toggle TX baud clock
            end else begin
                counter_tx <= counter_tx + 1; // Increment counter_tx
            end
        end
    end
	 
	 // Additional toggling logic for q1 based on rx_baud_clk
	 always @(posedge rx_baud_clk or posedge rst) begin
	     if (rst)
		    q1 <= 0;
		  else
		     q1 <= ~q1; // Toggle q1 on the rising edge of rx_baud_clk
	 end
	 
	 // Additional toggling logic for q2 based on q1
	 always @(posedge q1 or posedge rst) begin
	     if (rst)
		    q2 <= 0;
		  else
		     q2 <= ~q2; // Toggle q2 on the rising edge of q1
	 end
		  
endmodule
