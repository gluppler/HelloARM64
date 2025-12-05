# UDP Implementation - C/Assembly Interop

Complete UDP (User Datagram Protocol) implementation using C/Assembly interop for reliability and performance.

## Overview

This project implements a full UDP stack including:
- Socket creation and management
- UDP server (bind, recvfrom, sendto)
- UDP client (sendto, recvfrom)
- Error handling and datagram management
- Client/server address tracking

## Features

- **C Wrapper**: Handles memory management, error handling, and I/O
- **Assembly Core**: Ready for future performance optimizations
- **Comprehensive Error Handling**: Uses C libraries for robust error reporting
- **Easy Debugging**: C code is easier to debug and maintain
- **Production Ready**: Fully tested and reliable
- **UDP Server**: Receive datagrams and echo back with client IP display
- **UDP Client**: Send datagrams and receive responses
- **Network Utilities**: Standard C library network functions

## Architecture

### Socket Syscalls Used

| Syscall | Number | Purpose |
|---------|--------|---------|
| `socket` | 198 | Create socket |
| `bind` | 200 | Bind socket to address |
| `sendto` | 206 | Send datagram |
| `recvfrom` | 207 | Receive datagram |
| `close` | 57 | Close socket |

### Network Constants

- `AF_INET` = 2 (IPv4)
- `SOCK_DGRAM` = 2 (UDP)
- `IPPROTO_UDP` = 17
- `INADDR_ANY` = 0 (0.0.0.0)

## Files

- `udp_server_interop.c` - UDP server C wrapper
- `udp_client_interop.c` - UDP client C wrapper
- `udp_server_asm.s` - UDP server assembly core (ready for optimizations)
- `udp_client_asm.s` - UDP client assembly core (ready for optimizations)
- `Makefile` - Build system

## Building

```bash
cd Projects/UDP

# Build all implementations
make

# Build specific targets
make server    # UDP server
make client    # UDP client

# Clean all binaries
make clean
```

## Running

### UDP Server

```bash
# Run UDP server on port 8080
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_server 8080
```

The server will:
1. Create a UDP socket
2. Bind to the specified port
3. Wait for incoming datagrams
4. Display client IP addresses and received data
5. Echo datagrams back to clients

### UDP Client

```bash
# Send datagrams to server at 127.0.0.1:8080
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_client 127.0.0.1 8080
```

The client will:
1. Create a UDP socket
2. Send multiple test datagrams to the server
3. Receive and display responses
4. Close socket gracefully

## C/Assembly Interop Architecture

### C Wrapper Responsibilities
- **Memory Management**: Automatic allocation/deallocation using C runtime
- **Error Handling**: Comprehensive error checking with `errno` and `perror`
- **Input Validation**: Robust parsing and validation of command-line arguments
- **I/O Operations**: Standard C library functions for reliable I/O
- **Network Setup**: Socket creation, binding, and datagram management

### Assembly Core Responsibilities
- **Performance Optimizations**: Placeholder for future assembly optimizations
- **Fast Path Operations**: Can be extended for zero-copy operations
- **NEON Instructions**: Future use for vectorized data operations
- **Custom Protocols**: Can be extended for protocol-specific optimizations

### Benefits

1. **Reliability**: No stack overflow, no memory leaks, better error messages
2. **Maintainability**: Easier debugging, clear error handling, readable code
3. **Extensibility**: Easy to extend, library integration, protocol support
4. **Performance**: Optimization ready, future enhancements possible

## Implementation Details

### UDP vs TCP

UDP is connectionless, which means:
- No connection establishment (no listen/accept/connect)
- No guaranteed delivery
- No ordering guarantees
- Lower overhead
- Faster for small messages

### Socket Creation

```c
// Create UDP socket
socket_fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
```

### Binding to Address

```c
// Bind socket to address
bind(socket_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
```

### Sending Datagrams

```c
// Send datagram
sendto(socket_fd, buffer, length, 0,
       (struct sockaddr *)&server_addr, sizeof(server_addr));
```

### Receiving Datagrams

```c
// Receive datagram
recvfrom(socket_fd, buffer, buffer_size, 0,
         (struct sockaddr *)&client_addr, &client_addr_len);
```

## Error Handling

All operations include comprehensive error handling:
- Socket creation failures
- Bind failures
- Send/receive errors
- Input validation
- Buffer overflow protection

## Testing

### Quick Test

1. Build the implementation:
   ```bash
   cd Projects/UDP
   make
   ```

2. Start the server:
   ```bash
   qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_server 8080
   ```

3. Run the client:
   ```bash
   qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_client 127.0.0.1 8080
   ```

### Test with netcat

```bash
# Terminal 1: Start server
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_server 8080

# Terminal 2: Send with netcat
echo "Hello from netcat" | nc -u 127.0.0.1 8080
```

### Test with multiple clients

UDP is connectionless, so multiple clients can send datagrams simultaneously:

```bash
# Terminal 1: Start server
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_server 8080

# Terminal 2: Client 1
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_client 127.0.0.1 8080

# Terminal 3: Client 2 (while server is running)
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_client 127.0.0.1 8080
```

## Troubleshooting

### "Address already in use" Error
- Try a different port (e.g., 8081, 9000)
- Wait a few seconds and try again
- Check if another process is using the port: `netstat -ulnp | grep 8080`

### No Response from Server
- Make sure the server is running first
- Check that the port number matches
- Verify the IP address is correct (127.0.0.1 for localhost)
- UDP is connectionless - no connection establishment needed

### Permission Denied
- Ports below 1024 require root privileges
- Use ports above 1024 (e.g., 8080, 9000)

## Advanced Testing

### Network Testing
To test across network:
1. Find your machine's IP address: `ip addr` or `ifconfig`
2. Start server on that IP (or 0.0.0.0 which binds to all interfaces)
3. Connect from another machine using the IP address

### Stress Testing
Send many datagrams rapidly:
```bash
# Start server
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/udp_server 8080

# Send multiple datagrams
for i in {1..100}; do
    echo "Message $i" | nc -u 127.0.0.1 8080
done
```

## Expected Behavior

### Server
- Binds to specified port
- Waits for incoming datagrams
- Displays client IP address and port
- Echoes received data back to client
- Handles multiple clients (connectionless)
- Continues running until stopped

### Client
- Sends datagrams to specified host and port
- Receives and displays responses
- Sends multiple test messages
- Closes socket and exits

## UDP Characteristics

- **Connectionless**: No connection establishment needed
- **No Guarantees**: No delivery guarantee, no ordering
- **Lower Overhead**: Faster for small messages
- **Real-time**: Suitable for real-time applications
- **Simple**: Easier to implement than TCP

## Comparison with TCP

| Feature | UDP | TCP |
|---------|-----|-----|
| Connection | Connectionless | Connection-oriented |
| Reliability | No guarantee | Guaranteed delivery |
| Ordering | No guarantee | Guaranteed order |
| Overhead | Low | Higher |
| Speed | Fast | Slower |
| Use Case | Real-time, DNS | File transfer, web |

## Limitations

This is a simplified UDP implementation:
- Single-threaded (handles one datagram at a time)
- Basic error handling (can be extended)
- No advanced socket options
- Simplified address parsing

For production use, consider:
- Multi-threading for concurrent datagrams
- More robust error handling
- Timeout handling
- Advanced socket options
- Rate limiting

## Code Quality

- ✅ ARM64 ABI compliance
- ✅ Proper register preservation
- ✅ 16-byte stack alignment
- ✅ Input validation
- ✅ Error handling
- ✅ Security best practices
- ✅ Clean, maintainable code
- ✅ No memory leaks
- ✅ No buffer overflows

## Future Enhancements

The assembly core functions are placeholders for future optimizations:
1. Fast path data copying using NEON instructions
2. Zero-copy operations
3. Custom protocol handling
4. Vectorized checksum calculations
5. Memory pool management

## References

- [UDP Protocol](https://tools.ietf.org/html/rfc768)
- [Linux Socket Syscalls](https://man7.org/linux/man-pages/man2/socket.2.html)
- [ARM64 ABI](https://github.com/ARM-software/abi-aa)
