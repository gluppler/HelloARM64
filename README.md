# HelloARM64

HelloARM64/
├── README.md
├── baremetal/                # Track 1: CPU-only thinking
│   ├── 00_registers/         # Playgrounds for registers/instructions
│   │   ├── main.s
│   │   └── Makefile
│   ├── 01_arithmetic/
│   ├── 02_memory/
│   ├── 03_functions/
│   └── projects/
│       ├── fibonacci.s
│       └── bubblesort.s
│
├── systems/                  # Track 2: macOS + assembly
│   ├── 00_hello_syscall/
│   │   ├── hello.s
│   │   └── Makefile
│   ├── 01_calling_convention/
│   ├── 02_mixing_c/
│   │   ├── asm_func.s
│   │   ├── main.c
│   │   └── Makefile
│   ├── 03_debugging/
│   └── projects/
│       ├── strlen/
│       │   ├── strlen.s
│       │   ├── main.c
│       │   └── Makefile
│       └── factorial.s
│
└── tools/                    # Helpful scripts/configs
    └── build.sh
