import serial
import threading
import time

# File paths
input_file = "input.txt"
output_file = "output_matrices_parallel.txt"

# UART configuration
uart_port = "COM5"  # Replace with your UART port
baud_rate = 9600  # Match FPGA baud rate

# Global variables for thread-safe result handling
results = []  # Stores received results
results_lock = threading.Lock()  # Lock to ensure thread-safe access
running = True  # Flag to manage the UART reading thread

def read_matrices(filename):
    """
    Read the matrix data from the input file.
    Assumes the file contains lines with 18 matrix entries (9 for A and 9 for B).
    """
    with open(filename, "r") as file:
        matrices = []
        for line in file:
            matrices.append([int(x) for x in line.strip().split()])
        print(f"Read matrices: {matrices}")  # Debugging line to check matrices
        return matrices

def write_results(filename, results):
    """
    Write the results to the output file.
    """
    with open(filename, "w") as file:
        for result in results:
            file.write(" ".join(map(str, result)) + "\n")

def matrix_to_bytes(matrix):
    """
    Convert a 9x integer matrix into a byte array for transmission.
    Each integer value is sent as one byte.
    """
    packed_bytes = bytes(matrix)  # Directly convert the list of integers to bytes
    return packed_bytes

def bytes_to_matrix(data):
    """
    Convert the received 9 bytes of result back into 9 matrix entries.
    Each byte corresponds to one integer.
    """
    return list(data)  # Each byte represents an 8-bit value, which is the matrix element

def send_matrix(ser, matrix):
    """
    Send a matrix over UART.
    """
    packed_bytes = matrix_to_bytes(matrix)
    print(f"Transmitting: {packed_bytes}")  # Print the packed bytes for debugging
    ser.write(packed_bytes)

def uart_reader(ser, timeout=5):
    """
    Thread function to continuously read data from UART.
    """
    global results, running
    start_time = time.time()

    while running:
        try:
            if ser.is_open and ser.in_waiting > 0:
                data = ser.read(9)  # Read 9 bytes from the FPGA
                if len(data) == 9:
                    print(f"Received: {list(data)}")  # Print received data for debugging
                    matrix = bytes_to_matrix(data)
                    with results_lock:
                        results.append(matrix)
                else:
                    print(f"Error: Incomplete data received. Expected 9 bytes, got {len(data)} bytes.")
            else:
                if time.time() - start_time > timeout:
                    print("Timeout reached while waiting for data.")
                    break
                time.sleep(0.01)  # Avoid busy waiting
        except serial.SerialException as e:
            print(f"Serial exception: {e}")
            break
        except Exception as e:
            print(f"Unexpected error: {e}")
            break

def main():
    global running
    matrices = read_matrices(input_file)

    with serial.Serial(uart_port, baud_rate, timeout=5) as ser:
        # Start the UART reading thread
        reader_thread = threading.Thread(target=uart_reader, args=(ser,), daemon=True)
        reader_thread.start()

        try:
            # Send matrices to FPGA
            for matrix_pair in matrices:
                matA, matB = matrix_pair[:9], matrix_pair[9:]
                send_matrix(ser, matA)
                send_matrix(ser, matB)
                #time.sleep(0.1)  # Allow time for data processing

            # Allow time for the UART thread to process incoming data
            print("Waiting for FPGA responses...")
            time.sleep(0.8)  # Increase the wait time for FPGA response
        finally:
            # Stop the thread gracefully
            running = False
            reader_thread.join()

    # Write results to file
    with results_lock:
        write_results(output_file, results)
    print("Processing complete. Results saved to", output_file)

if __name__ == "__main__":
    main()