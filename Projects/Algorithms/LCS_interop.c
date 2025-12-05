/*
 * LCS Interop - C wrapper for ARM64 LCS assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

extern uint32_t lcs_asm(char* str1, char* str2, uint32_t m, uint32_t n);

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
    printf("    LCS (Longest Common Subsequence)\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    char str1[] = "ABCDGH";
    char str2[] = "AEDFHR";
    
    uint32_t m = strlen(str1);
    uint32_t n = strlen(str2);
    
    printf("Test: str1 = \"%s\", str2 = \"%s\"\n", str1, str2);
    printf("str1 length: %u, str2 length: %u\n", m, n);
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    uint32_t result = lcs_asm(str1, str2, m, n);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    printf("Result: LCS length = %u\n", result);
    printf("Status: LCS calculation completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    return 0;
}
