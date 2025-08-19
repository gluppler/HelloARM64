.global _main
.align 4

_main:
    mov x0, #5
    mov x1, #10
    add x0, x0, x1    // x0 = 15
    ret               // return 15 from main()
