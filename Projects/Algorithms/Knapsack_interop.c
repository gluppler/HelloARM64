/*
 * Knapsack Interop - C wrapper for ARM64 Knapsack assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

extern int32_t knapsack_asm(int32_t* weights, int32_t* values, uint32_t n, uint32_t capacity);

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
    printf("    0/1 Knapsack Problem\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    //  Test case
    int32_t weights[] = {10, 20, 30};
    int32_t values[] = {60, 100, 120};
    uint32_t n = 3;
    uint32_t capacity = 50;
    
    printf("Test: n = %u, capacity = %u\n", n, capacity);
    printf("Weights: [");
    for (uint32_t i = 0; i < n; i++) {
        printf("%d%s", weights[i], (i < n - 1) ? ", " : "");
    }
    printf("]\n");
    printf("Values: [");
    for (uint32_t i = 0; i < n; i++) {
        printf("%d%s", values[i], (i < n - 1) ? ", " : "");
    }
    printf("]\n");
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    int32_t result = knapsack_asm(weights, values, n, capacity);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    printf("Result: Maximum value = %d\n", result);
    printf("Status: Knapsack calculation completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    return 0;
}
