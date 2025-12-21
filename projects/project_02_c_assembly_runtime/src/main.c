// C program testing ARM64 assembly runtime functions
#include <stdio.h>
#include <string.h>

// Declare assembly functions
extern void *memcpy(void *dest, const void *src, size_t n);
extern void *memset(void *s, int c, size_t n);
extern size_t strlen(const char *s);
extern int strcmp(const char *s1, const char *s2);

int main(void) {
    char buffer1[100];
    char buffer2[100];
    const char *test_str = "Hello, ARM64!";
    
    // Test memset
    memset(buffer1, 'A', 50);
    buffer1[50] = '\0';
    printf("memset test: %s\n", buffer1);
    
    // Test memcpy
    memcpy(buffer2, test_str, strlen(test_str) + 1);
    printf("memcpy test: %s\n", buffer2);
    
    // Test strlen
    size_t len = strlen(test_str);
    printf("strlen('%s') = %zu\n", test_str, len);
    
    // Test strcmp
    int cmp1 = strcmp("abc", "abc");
    int cmp2 = strcmp("abc", "def");
    int cmp3 = strcmp("def", "abc");
    printf("strcmp('abc', 'abc') = %d\n", cmp1);
    printf("strcmp('abc', 'def') = %d\n", cmp2);
    printf("strcmp('def', 'abc') = %d\n", cmp3);
    
    return 0;
}
