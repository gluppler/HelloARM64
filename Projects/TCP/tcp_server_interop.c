/*
 * TCP Server - C/Assembly Interop Implementation
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
// extern void tcp_server_asm(int server_fd, int client_fd);

// Function to handle client connection
static void handle_client(int client_fd) {
    char buffer[1024];
    ssize_t bytes_received;
    
    printf("Connection accepted! Client FD: %d\n", client_fd);
    
    // Echo loop: receive and send back
    while (1) {
        bytes_received = recv(client_fd, buffer, sizeof(buffer) - 1, 0);
        
        if (bytes_received <= 0) {
            if (bytes_received == 0) {
                printf("Client disconnected (EOF)\n");
            } else {
                perror("recv error");
            }
            break;
        }
        
        // Null-terminate for safety
        buffer[bytes_received] = '\0';
        
        printf("Received (%zd bytes): %s", bytes_received, buffer);
        
        // Echo data back to client
        ssize_t bytes_sent = send(client_fd, buffer, bytes_received, 0);
        if (bytes_sent < 0) {
            perror("send error");
            break;
        }
        
        if (bytes_sent != bytes_received) {
            printf("Warning: Partial send (%zd/%zd bytes)\n", bytes_sent, bytes_received);
        }
    }
    
    printf("Connection closed.\n");
}

// Main server function
static int run_server(uint16_t port) {
    int server_fd, client_fd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_addr_len = sizeof(client_addr);
    int opt = 1;
    
    // Create TCP socket
    server_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (server_fd < 0) {
        perror("socket creation failed");
        return 1;
    }
    
    // Set SO_REUSEADDR option
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        perror("setsockopt failed");
        close(server_fd);
        return 1;
    }
    
    // Prepare server address structure
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;  // Listen on all interfaces
    server_addr.sin_port = htons(port);
    
    // Bind socket to address
    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind failed");
        close(server_fd);
        return 1;
    }
    
    // Listen for connections
    if (listen(server_fd, 10) < 0) {
        perror("listen failed");
        close(server_fd);
        return 1;
    }
    
    printf("========================================\n");
    printf("    TCP Server (C/Assembly Interop)\n");
    printf("========================================\n");
    printf("Server listening on port %d\n", port);
    printf("Waiting for connections...\n\n");
    
    // Main server loop
    while (1) {
        // Accept incoming connection
        client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_addr_len);
        if (client_fd < 0) {
            perror("accept failed");
            continue;  // Continue listening on error
        }
        
        // Print client information
        char client_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &client_addr.sin_addr, client_ip, INET_ADDRSTRLEN);
        printf("New connection from %s:%d\n", client_ip, ntohs(client_addr.sin_port));
        
        // Handle client connection
        handle_client(client_fd);
        
        // Close client socket
        close(client_fd);
    }
    
    // This point should never be reached, but clean up if it is
    close(server_fd);
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
