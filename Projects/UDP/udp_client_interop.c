/*
 * UDP Client - C/Assembly Interop Implementation
 * C wrapper handles memory management, error handling, and I/O
 * Assembly core ready for future performance optimizations
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <stdint.h>
#include <time.h>

// External assembly functions (for future optimizations)
// extern void udp_client_asm(int socket_fd, const void *data, size_t data_len);

// Function to send datagram and receive response
static int send_and_receive(int socket_fd, const char *host, uint16_t port,
                            const char *message) {
    struct sockaddr_in server_addr;
    ssize_t bytes_sent, bytes_received;
    char buffer[4096];
    socklen_t server_addr_len = sizeof(server_addr);
    
    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    
    // Convert host string to IP address
    if (inet_pton(AF_INET, host, &server_addr.sin_addr) <= 0) {
        fprintf(stderr, "Error: Invalid IP address: %s\n", host);
        return -1;
    }
    
    size_t message_len = strlen(message);
    
    // Send datagram
    printf("Sending: %s", message);
    bytes_sent = sendto(socket_fd, message, message_len, 0,
                        (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (bytes_sent < 0) {
        perror("sendto failed");
        return -1;
    }
    
    if (bytes_sent != (ssize_t)message_len) {
        printf("Warning: Partial send (%zd/%zu bytes)\n", bytes_sent, message_len);
    }
    
    // Receive response (with timeout simulation)
    // Note: UDP is connectionless, so we wait for response from server
    bytes_received = recvfrom(socket_fd, buffer, sizeof(buffer) - 1, 0,
                              (struct sockaddr *)&server_addr, &server_addr_len);
    if (bytes_received < 0) {
        perror("recvfrom failed");
        return -1;
    }
    
    if (bytes_received == 0) {
        printf("Server sent empty response\n");
        return 0;
    }
    
    // Null-terminate for safety
    if (bytes_received < (ssize_t)sizeof(buffer)) {
        buffer[bytes_received] = '\0';
    }
    
    // Validate received data size
    if (bytes_received >= (ssize_t)sizeof(buffer)) {
        printf("Warning: Response truncated (max %zu bytes)\n", sizeof(buffer) - 1);
        bytes_received = sizeof(buffer) - 1;
    }
    
    // Get server IP address
    char server_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &server_addr.sin_addr, server_ip, INET_ADDRSTRLEN);
    
    printf("Received %zd bytes from %s:%d\n", bytes_received,
           server_ip, ntohs(server_addr.sin_port));
    printf("Response: %.*s\n\n", (int)bytes_received, buffer);
    
    return 0;
}

// Main client function
static int run_client(const char *host, uint16_t port) {
    int socket_fd;
    
    // Create UDP socket
    socket_fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socket_fd < 0) {
        perror("socket creation failed");
        return 1;
    }
    
    printf("========================================\n");
    printf("    UDP Client (C/Assembly Interop)\n");
    printf("========================================\n");
    printf("Connecting to %s:%d...\n\n", host, port);
    
    // Send test messages
    const char *messages[] = {
        "Hello from UDP client!\n",
        "This is a test message.\n",
        "Testing UDP echo functionality.\n",
        "UDP is connectionless and fast!\n",
        NULL
    };
    
    for (int i = 0; messages[i] != NULL; i++) {
        if (send_and_receive(socket_fd, host, port, messages[i]) < 0) {
            break;
        }
        usleep(200000);  // 200ms delay between messages
    }
    
    // Close socket
    close(socket_fd);
    printf("Connection closed.\n");
    
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
