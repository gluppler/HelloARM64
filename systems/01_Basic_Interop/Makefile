# systems/00_hello_syscall/Makefile

TARGET = hello_syscall
SRC_ASM = hello.s
SRC_C = main.c
BIN = ../../bin/$(TARGET)

all: $(BIN)

$(BIN): $(SRC_ASM) $(SRC_C)
	@mkdir -p ../../bin
	clang -arch arm64 -o $(BIN) $(SRC_ASM) $(SRC_C)

run: $(BIN)
	$(BIN)

clean:
	rm -f ../../bin/$(TARGET) *.o
