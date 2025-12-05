/*
 * Tree Traversal Interop - C wrapper for ARM64 Tree Traversal assembly
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

extern void tree_traversal_asm(int32_t* tree, uint32_t root, uint32_t size);

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
    printf("    Tree Traversal Algorithm\n");
    printf("    C/Assembly Interop Version\n");
    printf("========================================\n");
    
    //  Array-based binary tree representation
    //  Tree: [1, 2, 3, 4, 5, 6, 7]
    //        1
    //       / \
    //      2   3
    //     / \ / \
    //    4  5 6  7
    int32_t tree[] = {1, 2, 3, 4, 5, 6, 7};
    uint32_t size = sizeof(tree) / sizeof(tree[0]);
    
    printf("Test: Tree size = %u, Root = 0\n", size);
    printf("Tree array: [");
    for (uint32_t i = 0; i < size; i++) {
        printf("%d%s", tree[i], (i < size - 1) ? ", " : "");
    }
    printf("]\n");
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    tree_traversal_asm(tree, 0, size);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    printf("Status: Tree traversal completed successfully\n");
    printf("Execution Time: ");
    print_time(get_elapsed_ns(&start, &end));
    printf("\n");
    
    return 0;
}
