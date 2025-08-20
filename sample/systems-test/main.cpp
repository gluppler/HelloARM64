#include <iostream>

// This function is implemented in hello-sys.s
extern "C" {
    void print_message_from_asm();
}

int main() {
    print_message_from_asm();
    return 0;
}