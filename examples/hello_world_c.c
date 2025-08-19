#include <stdio.h>

// Forward declaration (note: C calls get_message, asm defines _get_message)
const char* get_message(void);

int main(void) {
    const char* msg = get_message();
    printf("%s", msg);
    return 0;
}
