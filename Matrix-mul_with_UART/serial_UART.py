import serial
import time

# File paths
input_file = "input.txt"
output_file = "output_matrices_series.txt"

# UART configuration
uart_port = "COM5"  # Replace with your UART port
baud_rate = 9600  # Match FPGA baud rate


def read_matrices(filename):
    with open(filename, "r") as file:
        matrices = []
        for line in file:
            matrices.append([int(x) for x in line.strip().split()])
        return matrices


def write_results(filename, results):
    with open(filename, "w") as file:
        for result in results:
            file.write(" ".join(map(str, result)) + "\n")


def matrix_to_bytes(matrix):
    packed_bits = 0
    for i, value in enumerate(matrix):
        lsb_3_bits = value & 0b1111  # Mask to keep only the least 4 bits
        packed_bits |= (lsb_3_bits << (i * 4))  # Shift and pack into the 54-bit value
    packed_bytes = packed_bits.to_bytes(5, byteorder='little')  # Pack to 5 bytes
    return packed_bytes[:5]


def bytes_to_matrix(data):
    return [byte for byte in data]


def read_full_data(ser, num_bytes, timeout=5):
    result = b""
    start_time = time.time()
    while len(result) < num_bytes:
        if ser.in_waiting > 0:
            result += ser.read(num_bytes - len(result))  # Read remaining bytes
        if time.time() - start_time > timeout:
            print("Timeout reached while waiting for data.")
            break
    return result


def main():
    matrices = read_matrices(input_file)
    results = []

    with serial.Serial(uart_port, baud_rate, timeout=5) as ser:
        for matrix_pair in matrices:
            matA, matB = matrix_pair[:9], matrix_pair[9:]
            print(f"Sending MatA: {matrix_to_bytes(matA)}")
            print(f"Sending MatB: {matrix_to_bytes(matB)}")

            # Send matrices to FPGA
            ser.write(matrix_to_bytes(matA))
            ser.write(matrix_to_bytes(matB))
            print(f"Sent MatA and MatB.")

            # Wait for the result from FPGA
            result = read_full_data(ser, 9, timeout=5)
            if len(result) == 9:
                print(f"Received data: {result}")
                results.append(bytes_to_matrix(result))
            else:
                print(f"Error: Incomplete data received. Expected 9 bytes, got {len(result)} bytes.")

        result = read_full_data(ser, 9, timeout=5)  # Read remaining 9 bytes if available
        if len(result) == 9:
            print(f"Received additional data: {result}")
            results.append(bytes_to_matrix(result))

    # Write the results to the output file
    write_results(output_file, results)
    print("Processing complete. Results saved to", output_file)


if __name__ == "__main__":
    main()
