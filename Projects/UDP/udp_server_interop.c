/*
 * UDP Server - C/Assembly Interop Implementation
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

// External assembly functions (for future optimizations)
// extern void udp_server_asm(int socket_fd, void *buffer, size_t buffer_size);

// Function to handle received datagrams
static void handle_datagram(int socket_fd, char *buffer, ssize_t bytes_received,
                            struct sockaddr_in *client_addr, socklen_t client_addr_len) {
    char client_ip[INET_ADDRSTRLEN];
    
    // Null-terminate received data for safety
    if (bytes_received < (ssize_t)sizeof(buffer)) {
        buffer[bytes_received] = '\0';
    }
    
    // Get client IP address
    inet_ntop(AF_INET, &client_addr->sin_addr, client_ip, INET_ADDRSTRLEN);
    
    printf("Received %zd bytes from %s:%d\n", bytes_received, 
           client_ip, ntohs(client_addr->sin_port));
    printf("Data: %.*s\n", (int)bytes_received, buffer);
    
    // Echo data back to client
    ssize_t bytes_sent = sendto(socket_fd, buffer, bytes_received, 0,
                                (struct sockaddr *)client_addr, client_addr_len);
    if (bytes_sent < 0) {
        perror("sendto failed");
    } else if (bytes_sent != bytes_received) {
        printf("Warning: Partial send (%zd/%zd bytes)\n", bytes_sent, bytes_received);
    } else {
        printf("Echoed %zd bytes back to client\n\n", bytes_sent);
    }
}

// Main server function
static int run_server(uint16_t port) {
    int socket_fd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_addr_len = sizeof(client_addr);
    char buffer[4096];  // UDP datagram buffer
    ssize_t bytes_received;
    
    // Create UDP socket
    socket_fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socket_fd < 0) {
        perror("socket creation failed");
        return 1;
    }
    
    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;  // Listen on all interfaces
    server_addr.sin_port = htons(port);
    
    // Bind socket to address
    if (bind(socket_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind failed");
        close(socket_fd);
        return 1;
    }
    
    printf("========================================\n");
    printf("    UDP Server (C/Assembly Interop)\n");
    printf("========================================\n");
    printf("Server listening on port %d\n", port);
    printf("Waiting for datagrams...\n\n");
    
    // Main server loop
    while (1) {
        // Receive datagram
        bytes_received = recvfrom(socket_fd, buffer, sizeof(buffer) - 1, 0,
                                   (struct sockaddr *)&client_addr, &client_addr_len);
        
        if (bytes_received < 0) {
            perror("recvfrom failed");
            continue;  // Continue listening on error
        }
        
        if (bytes_received == 0) {
            printf("Received empty datagram\n");
            continue;
        }
        
        // Validate received data size
        if (bytes_received >= (ssize_t)sizeof(buffer)) {
            printf("Warning: Datagram truncated (max %zu bytes)\n", sizeof(buffer) - 1);
            bytes_received = sizeof(buffer) - 1;
        }
        
        // Handle the datagram
        handle_datagram(socket_fd, buffer, bytes_received, &client_addr, client_addr_len);
    }
    
    // This point should never be reached, but clean up if it is
    close(socket_fd);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <port>\n", argv[0]);
        fprintf(stderr, "Example: %s 8080\n", argv[0]);
        return 1;
    }
    
    // Parse port number
    char *endptr;
    long port = strtol(argv[1], &endptr, 10);
    
    // Validate port number
    if (*endptr != '\0' || port <= 0 || port > 65535) {
        fprintf(stderr, "Error: Invalid port number. Must be between 1 and 65535.\n");
        return 1;
    }
    
    // Run server
    return run_server((uint16_t)port);
}
