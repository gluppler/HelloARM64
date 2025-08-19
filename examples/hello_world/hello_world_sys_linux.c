// examples/hello_world/hello_world_sys_linux.c
#include <stdio.h>

const char * get_message(void); // implemented in ASM

int main(void) {
    const char *m = get_message();
    puts(m);
    return 0;
}
