/*
 * Rabin-Karp Interop - C wrapper for ARM64 Rabin-Karp assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

extern int32_t rabin_karp_asm(char* text, uint32_t text_len, char* pattern, uint32_t pattern_len);

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
    printf("    Rabin-Karp String Matching\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    char text[] = "GEEKS FOR GEEKS";
    char pattern[] = "GEEK";
    
    uint32_t text_len = strlen(text);
    uint32_t pattern_len = strlen(pattern);
    
    printf("Test: Text = \"%s\", Pattern = \"%s\"\n", text, pattern);
    printf("Text length: %u, Pattern length: %u\n", text_len, pattern_len);
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    int32_t result = rabin_karp_asm(text, text_len, pattern, pattern_len);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    if (result >= 0) {
        printf("Result: Pattern found at index %d\n", result);
    } else {
        printf("Result: Pattern not found\n");
    }
    printf("Status: Rabin-Karp search completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    return 0;
}
