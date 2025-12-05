/*
 * Binary Search Interop - C wrapper for ARM64 Binary Search assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

extern int32_t binary_search_asm(int32_t* array, int32_t left, int32_t right, int32_t target);

int compare_int(const void* a, const void* b) {
    int32_t ia = *(int32_t*)a;
    int32_t ib = *(int32_t*)b;
    return (ia > ib) - (ia < ib);
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
    printf("    Binary Search Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    //  Test 1: Small array
    int32_t arr1[] = {1, 3, 5, 7, 9, 11, 13, 15};
    int size1 = sizeof(arr1) / sizeof(arr1[0]);
    int32_t target1 = 7;
    
    printf("Test 1: Array size = %d, Target = %d\n", size1, target1);
    printf("Array: [");
    for (int i = 0; i < size1; i++) {
        printf("%d%s", arr1[i], (i < size1 - 1) ? ", " : "");
    }
    printf("]\n");
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    int32_t result1 = binary_search_asm(arr1, 0, size1 - 1, target1);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    printf("Result: [%d]\n", result1);
    printf("Status: Binary search completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    //  Test 2: Larger array
    int32_t* arr2 = (int32_t*)malloc(100 * sizeof(int32_t));
    for (int i = 0; i < 100; i++) {
        arr2[i] = i * 2;  //  Even numbers 0, 2, 4, ...
    }
    int32_t target2 = 50;
    
    printf("Test 2: Array size = 100, Target = %d\n", target2);
    
    clock_gettime(CLOCK_MONOTONIC, &start);
    int32_t result2 = binary_search_asm(arr2, 0, 99, target2);
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    printf("Result: [%d]\n", result2);
    printf("Status: Binary search completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    free(arr2);
    return 0;
}
