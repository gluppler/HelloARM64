// C program that calls ARM64 assembly function
#include <stdio.h>

// Declare external assembly function
extern int add(int a, int b);

int main(void) {
    int result = add(10, 20);
    printf("10 + 20 = %d\n", result);
    return 0;
}

// Compilation:
// gcc -o add_test main.c add.s
