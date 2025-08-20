// systems/00_hello_syscall/main.c
#include <stdio.h>

// Assembly function declaration
void write_message(void);

int main(void) {
    write_message();  // call into ASM
    return 0;
}
