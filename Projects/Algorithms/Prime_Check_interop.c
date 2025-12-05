/*
 * Prime Check Interop - C wrapper for ARM64 Prime Check assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

extern uint64_t prime_check_asm(uint64_t n);

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
    printf("    Prime Check Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    uint64_t test_cases[] = {2, 17, 100, 997, 1000};
    int num_tests = sizeof(test_cases) / sizeof(test_cases[0]);
    
    for (int i = 0; i < num_tests; i++) {
        uint64_t n = test_cases[i];
        printf("Test %d: n = %llu\n", i + 1, n);
        printf("Input: [%llu]\n", n);
        
        struct timespec start, end;
        clock_gettime(CLOCK_MONOTONIC, &start);
        
        uint64_t result = prime_check_asm(n);
        
        clock_gettime(CLOCK_MONOTONIC, &end);
        
        printf("Result: [%s]\n", result ? "Prime" : "Not Prime");
        printf("Status: Prime check completed successfully\n");
        printf("Execution Time: ");
        print_time(get_elapsed_ns(&start, &end));
        printf("\n");
    }
    
    return 0;
}
