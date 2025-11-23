CFLAGS = -m32 -g
ASMFLAGS = -f elf32 -g
LDFLAGS = -m32

all: programa

programa: persona_asm.o persona_c.o
	gcc $(LDFLAGS) -o programa persona_asm.o persona_c.o

persona_asm.o: persona.asm
	nasm $(ASMFLAGS) persona.asm -o persona_asm.o

persona_c.o: persona.c persona.h
	gcc $(CFLAGS) -c persona.c -o persona_c.o

clean:
	rm -f *.o programa

.PHONY: all clean