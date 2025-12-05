/*
 * DFS Interop - C wrapper for ARM64 DFS assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

extern void dfs_asm(uint8_t* graph, uint8_t* visited, uint32_t node, uint32_t num_nodes);

void generate_random_graph(uint8_t* graph, uint32_t num_nodes, uint64_t seed) {
    uint64_t state = seed;
    for (uint32_t i = 0; i < num_nodes; i++) {
        for (uint32_t j = 0; j < num_nodes; j++) {
            if (i == j) {
                graph[i * num_nodes + j] = 0;
            } else {
                state = (state * 1103515245ULL + 12345ULL) & 0x7FFFFFFFULL;
                graph[i * num_nodes + j] = (state % 3 == 0) ? 1 : 0;
            }
        }
    }
}

void print_graph(uint8_t* graph, uint32_t num_nodes) {
    printf("Graph Matrix:\n");
    for (uint32_t i = 0; i < num_nodes; i++) {
        for (uint32_t j = 0; j < num_nodes; j++) {
            printf("%d ", graph[i * num_nodes + j]);
        }
        printf("\n");
    }
}

void print_visited(uint8_t* visited, uint32_t num_nodes) {
    printf("DFS Traversal Order: [");
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

uint64_t get_elapsed_ns(struct timespec* start, struct timespec* end) {
    uint64_t elapsed_sec = end->tv_sec - start->tv_sec;
    int64_t elapsed_nsec = end->tv_nsec - start->tv_nsec;
    if (elapsed_nsec < 0) {
        elapsed_sec--;
        elapsed_nsec += 1000000000L;
    }
    return elapsed_sec * 1000000000ULL + elapsed_nsec;
}

void print_time(uint64_t elapsed_ns) {
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
    printf("    DFS (Depth-First Search) Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    //  Test 1: Small graph
    uint32_t num_nodes = 5;
    uint64_t seed = 1;
    
    size_t graph_size = num_nodes * num_nodes * sizeof(uint8_t);
    size_t visited_size = num_nodes * sizeof(uint8_t);
    
    uint8_t* graph = (uint8_t*)malloc(graph_size);
    uint8_t* visited = (uint8_t*)malloc(visited_size);
    
    if (!graph || !visited) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    memset(graph, 0, graph_size);
    memset(visited, 0, visited_size);
    
    generate_random_graph(graph, num_nodes, seed);
    print_graph(graph, num_nodes);
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    dfs_asm(graph, visited, 0, num_nodes);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    print_visited(visited, num_nodes);
    printf("Status: DFS traversal completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    free(graph);
    free(visited);
    
    return 0;
}
