/*
 * TCP Client - C/Assembly Interop Implementation
 * C wrapper handles memory management, error handling, and I/O
 * Assembly core handles performance-critical socket operations
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <errno.h>
#include <stdint.h>

// External assembly functions (for future optimizations)
// extern void tcp_client_asm(int socket_fd, const char *message, size_t message_len);

// Function to send message and receive response
static int send_and_receive(int socket_fd, const char *message) {
    size_t message_len = strlen(message);
    ssize_t bytes_sent, bytes_received;
    char buffer[1024];
    
    // Send message
    printf("Sending: %s", message);
    bytes_sent = send(socket_fd, message, message_len, 0);
    if (bytes_sent < 0) {
        perror("send failed");
        return -1;
    }
    
    if (bytes_sent != (ssize_t)message_len) {
        printf("Warning: Partial send (%zd/%zu bytes)\n", bytes_sent, message_len);
    }
    
    // Receive response
    bytes_received = recv(socket_fd, buffer, sizeof(buffer) - 1, 0);
    if (bytes_received < 0) {
        perror("recv failed");
        return -1;
    }
    
    if (bytes_received == 0) {
        printf("Server closed connection\n");
        return 0;
    }
    
    // Null-terminate for safety
    buffer[bytes_received] = '\0';
    
    printf("Received (%zd bytes): %s", bytes_received, buffer);
    
    return 0;
}

// Main client function
static int run_client(const char *host, uint16_t port) {
    int socket_fd;
    struct sockaddr_in server_addr;
    
    // Create TCP socket
    socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (socket_fd < 0) {
        perror("socket creation failed");
        return 1;
    }
    
    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    
    // Convert host string to IP address
    if (inet_pton(AF_INET, host, &server_addr.sin_addr) <= 0) {
        fprintf(stderr, "Error: Invalid IP address: %s\n", host);
        close(socket_fd);
        return 1;
    }
    
    printf("========================================\n");
    printf("    TCP Client (C/Assembly Interop)\n");
    printf("========================================\n");
    printf("Connecting to %s:%d...\n", host, port);
    
    // Connect to server
    if (connect(socket_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("connect failed");
        close(socket_fd);
        return 1;
    }
    
    printf("Connected to server!\n\n");
    
    // Send test messages
    const char *messages[] = {
        "Hello from TCP client!\n",
        "This is a test message.\n",
        "Testing echo functionality.\n",
        NULL
    };
    
    for (int i = 0; messages[i] != NULL; i++) {
        if (send_and_receive(socket_fd, messages[i]) < 0) {
            break;
        }
        usleep(100000);  // 100ms delay between messages
    }
    
    // Close socket
    close(socket_fd);
    printf("\nConnection closed.\n");
    
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <host> <port>\n", argv[0]);
        fprintf(stderr, "Example: %s 127.0.0.1 8080\n", argv[0]);
        return 1;
    }
    
    // Parse port number
    char *endptr;
    long port = strtol(argv[2], &endptr, 10);
    
    // Validate port number
    if (*endptr != '\0' || port <= 0 || port > 65535) {
        fprintf(stderr, "Error: Invalid port number. Must be between 1 and 65535.\n");
        return 1;
    }
    
    // Run client
    return run_client(argv[1], (uint16_t)port);
}
