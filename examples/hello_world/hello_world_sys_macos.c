// examples/hello_world/hello_world_sys_macos.c
#include <stdio.h>

const char * get_message(void); // C prototype (no underscore here)

int main(void) {
    const char *m = get_message();
    puts(m);
    return 0;
}
