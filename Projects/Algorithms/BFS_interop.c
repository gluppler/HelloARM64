/*
 * BFS Interop - C wrapper for ARM64 BFS assembly implementation
 * Handles memory allocation/deallocation to avoid stack issues
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdint.h>
#include <sys/time.h>

// External assembly functions
extern void bfs_asm(uint8_t* graph, uint32_t num_nodes, uint32_t start, 
                    uint8_t* visited, uint64_t* queue);
extern void generate_random_graph_asm(uint8_t* graph, uint32_t num_nodes, uint64_t seed);

// Helper function to generate random graph (C implementation)
void generate_random_graph(uint8_t* graph, uint32_t num_nodes, uint64_t seed) {
    // Simple LCG for random number generation
    uint64_t state = seed;
    for (uint32_t i = 0; i < num_nodes; i++) {
        for (uint32_t j = 0; j < num_nodes; j++) {
            if (i == j) {
                graph[i * num_nodes + j] = 0;  // No self-loops
            } else {
                // LCG: state = (state * 1103515245 + 12345) & 0x7FFFFFFF
                state = (state * 1103515245ULL + 12345ULL) & 0x7FFFFFFFULL;
                graph[i * num_nodes + j] = (state % 3 == 0) ? 1 : 0;  // ~33% edge probability
            }
        }
    }
}

// Helper function to print graph
void print_graph(uint8_t* graph, uint32_t num_nodes) {
    printf("Graph Matrix:\n");
    for (uint32_t i = 0; i < num_nodes; i++) {
        for (uint32_t j = 0; j < num_nodes; j++) {
            printf("%d ", graph[i * num_nodes + j]);
        }
        printf("\n");
    }
}

// Helper function to print visited nodes
void print_visited(uint8_t* visited, uint32_t num_nodes) {
    printf("BFS Traversal Order: [");
    int first = 1;
    for (uint32_t i = 0; i < num_nodes; i++) {
        if (visited[i]) {
            if (!first) printf(", ");
            printf("%u", i);
            first = 0;
        }
    }
    printf("]\n");
}

// Calculate elapsed time in nanoseconds
uint64_t get_elapsed_ns(struct timespec* start, struct timespec* end) {
    uint64_t elapsed_sec = end->tv_sec - start->tv_sec;
    int64_t elapsed_nsec = end->tv_nsec - start->tv_nsec;
    
    if (elapsed_nsec < 0) {
        elapsed_sec--;
        elapsed_nsec += 1000000000L;
    }
    
    return elapsed_sec * 1000000000ULL + elapsed_nsec;
}

// Print execution time
void print_time(uint64_t elapsed_ns) {
    printf("Execution Time: ");
    if (elapsed_ns < 1000) {
        printf("%llu nanoseconds\n", elapsed_ns);
    } else if (elapsed_ns < 1000000) {
        printf("%llu.%03llu microseconds\n", elapsed_ns / 1000, elapsed_ns % 1000);
    } else if (elapsed_ns < 1000000000) {
        printf("%llu.%03llu milliseconds\n", elapsed_ns / 1000000, (elapsed_ns % 1000000) / 1000);
    } else {
        printf("%llu.%03llu seconds\n", elapsed_ns / 1000000000, (elapsed_ns % 1000000000) / 1000000);
    }
}

int main() {
    printf("========================================\n");
    printf("    BFS (Breadth-First Search) Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    // Test 1: Smallest graph (5 nodes)
    printf("Test 1: Smallest Graph (Randomized, 5 nodes)\n");
    uint32_t num_nodes = 5;
    uint64_t seed = 1;
    
    // Allocate memory on heap (not stack)
    size_t graph_size = num_nodes * num_nodes * sizeof(uint8_t);
    size_t visited_size = num_nodes * sizeof(uint8_t);
    size_t queue_size = num_nodes * sizeof(uint64_t);
    
    uint8_t* graph = (uint8_t*)malloc(graph_size);
    uint8_t* visited = (uint8_t*)malloc(visited_size);
    uint64_t* queue = (uint64_t*)malloc(queue_size);
    
    if (!graph || !visited || !queue) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    // Initialize arrays
    memset(graph, 0, graph_size);
    memset(visited, 0, visited_size);
    memset(queue, 0, queue_size);
    
    // Generate random graph
    generate_random_graph(graph, num_nodes, seed);
    
    // Print graph
    print_graph(graph, num_nodes);
    
    // Get start time
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    // Perform BFS from node 0
    bfs_asm(graph, num_nodes, 0, visited, queue);
    
    // Get end time
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    // Print results
    print_visited(visited, num_nodes);
    printf("Status: BFS traversal completed successfully\n");
    
    // Print timing
    uint64_t elapsed_ns = get_elapsed_ns(&start, &end);
    print_time(elapsed_ns);
    printf("\n");
    
    // Cleanup
    free(graph);
    free(visited);
    free(queue);
    
    // Test 2: Medium graph (8 nodes)
    printf("Test 2: Medium Graph (Randomized, 8 nodes)\n");
    num_nodes = 8;
    seed = 42;
    
    graph_size = num_nodes * num_nodes * sizeof(uint8_t);
    visited_size = num_nodes * sizeof(uint8_t);
    queue_size = num_nodes * sizeof(uint64_t);
    
    graph = (uint8_t*)malloc(graph_size);
    visited = (uint8_t*)malloc(visited_size);
    queue = (uint64_t*)malloc(queue_size);
    
    if (!graph || !visited || !queue) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    memset(graph, 0, graph_size);
    memset(visited, 0, visited_size);
    memset(queue, 0, queue_size);
    
    generate_random_graph(graph, num_nodes, seed);
    print_graph(graph, num_nodes);
    
    clock_gettime(CLOCK_MONOTONIC, &start);
    bfs_asm(graph, num_nodes, 0, visited, queue);
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    print_visited(visited, num_nodes);
    printf("Status: BFS traversal completed successfully\n");
    
    elapsed_ns = get_elapsed_ns(&start, &end);
    print_time(elapsed_ns);
    printf("\n");
    
    free(graph);
    free(visited);
    free(queue);
    
    // Test 3: Large graph (12 nodes)
    printf("Test 3: Large Graph (Randomized, 12 nodes)\n");
    num_nodes = 12;
    seed = 123;
    
    graph_size = num_nodes * num_nodes * sizeof(uint8_t);
    visited_size = num_nodes * sizeof(uint8_t);
    queue_size = num_nodes * sizeof(uint64_t);
    
    graph = (uint8_t*)malloc(graph_size);
    visited = (uint8_t*)malloc(visited_size);
    queue = (uint64_t*)malloc(queue_size);
    
    if (!graph || !visited || !queue) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    memset(graph, 0, graph_size);
    memset(visited, 0, visited_size);
    memset(queue, 0, queue_size);
    
    generate_random_graph(graph, num_nodes, seed);
    print_graph(graph, num_nodes);
    
    clock_gettime(CLOCK_MONOTONIC, &start);
    bfs_asm(graph, num_nodes, 0, visited, queue);
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    print_visited(visited, num_nodes);
    printf("Status: BFS traversal completed successfully\n");
    
    elapsed_ns = get_elapsed_ns(&start, &end);
    print_time(elapsed_ns);
    printf("\n");
    
    free(graph);
    free(visited);
    free(queue);
    
    return 0;
}
