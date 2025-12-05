/*
 * KMP Interop - C wrapper for ARM64 KMP assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

extern void compute_lps_asm(char* pattern, uint32_t pattern_len, int32_t* lps);
extern int32_t kmp_search_asm(char* text, uint32_t text_len, char* pattern, uint32_t pattern_len, int32_t* lps);

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
    printf("    KMP (Knuth-Morris-Pratt) Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    char text[] = "ABABDABACDABABCABCABAB";
    char pattern[] = "ABABCABAB";
    
    uint32_t text_len = strlen(text);
    uint32_t pattern_len = strlen(pattern);
    
    printf("Test: Text = \"%s\", Pattern = \"%s\"\n", text, pattern);
    printf("Text length: %u, Pattern length: %u\n", text_len, pattern_len);
    
    //  Allocate LPS array
    int32_t* lps = (int32_t*)malloc(pattern_len * sizeof(int32_t));
    if (!lps) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    //  Compute LPS array
    compute_lps_asm(pattern, pattern_len, lps);
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    int32_t result = kmp_search_asm(text, text_len, pattern, pattern_len, lps);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    if (result >= 0) {
        printf("Result: Pattern found at index %d\n", result);
    } else {
        printf("Result: Pattern not found\n");
    }
    printf("Status: KMP search completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    free(lps);
    return 0;
}
